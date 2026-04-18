defmodule App.Workers.GenerateSummary do
  use Oban.Worker, queue: :ai, max_attempts: 2

  alias App.{Assembly, Storage}
  alias App.Assembly.Meeting

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"meeting_id" => meeting_id}}) do
    meeting = Assembly.get_meeting!(meeting_id)
    current_hash = Assembly.content_hash(meeting)

    if meeting.summary_content_hash == current_hash && meeting.summary_pdf_url do
      :ok
    else
      with {:ok, markdown} <- call_claude(meeting),
           {:ok, pdf_path} <- markdown_to_pdf(markdown, meeting_id),
           s3_key = "meetings/#{meeting.condo_id}/#{meeting_id}/summary.pdf",
           {:ok, pdf_url} <- Storage.upload(pdf_path, s3_key, "application/pdf"),
           {:ok, updated} <- Assembly.save_summary(meeting, pdf_url, current_hash) do
        File.rm(pdf_path)
        Phoenix.PubSub.broadcast(App.PubSub, "meeting:#{meeting_id}", {:summary_ready, updated})
        :ok
      end
    end
  end

  defp call_claude(%Meeting{} = meeting) do
    api_key = Application.fetch_env!(:app, :anthropic_api_key)
    prompt = build_prompt(meeting)

    response =
      Req.post!("https://api.anthropic.com/v1/messages",
        headers: [
          {"x-api-key", api_key},
          {"anthropic-version", "2023-06-01"},
          {"content-type", "application/json"}
        ],
        json: %{
          model: "claude-sonnet-4-6",
          max_tokens: 4096,
          messages: [%{role: "user", content: prompt}]
        }
      )

    case response.body do
      %{"content" => [%{"text" => text} | _]} -> {:ok, text}
      body -> {:error, {:claude_error, body}}
    end
  end

  defp build_prompt(%Meeting{} = meeting) do
    items_text =
      meeting.agenda_items
      |> Enum.sort_by(& &1.order)
      |> Enum.map(fn item ->
        base = "#{item.order}. **#{item.title}**"
        desc = if item.description, do: "\n   #{item.description}", else: ""

        result =
          if item.resolution do
            "\n   Resultado: **#{item.resolution.result}** | #{item.resolution.votes_for} a favor, #{item.resolution.votes_against} contra, #{item.resolution.votes_abstain} abstenções"
          else
            ""
          end

        base <> desc <> result
      end)
      |> Enum.join("\n\n")

    """
    Você é um assistente especializado em assembleias de condomínio no Brasil.
    Gere um resumo executivo profissional desta assembleia em português, formatado em Markdown.

    O resumo deve conter:
    1. Cabeçalho com dados da assembleia (tipo, data, local, quórum)
    2. Resumo objetivo de cada item deliberado e seu resultado
    3. Conclusão geral com os principais pontos aprovados

    Use linguagem formal e jurídica adequada para documentos de condomínio.

    ---
    **Assembleia:** #{meeting.title}
    **Tipo:** #{meeting.type |> String.upcase()}
    **Data:** #{Calendar.strftime(meeting.scheduled_at, "%d/%m/%Y às %H:%M")}
    **Local:** #{meeting.location || "Não informado"}
    **Quórum exigido:** #{meeting.quorum_type}
    **Presenças registradas:** #{length(meeting.attendances)} unidades

    **Pauta:**
    #{items_text}
    #{if meeting.notes, do: "\n**Observações:** #{meeting.notes}", else: ""}
    ---
    """
  end

  defp markdown_to_pdf(markdown, meeting_id) do
    tmp_md = Path.join(System.tmp_dir!(), "meeting_#{meeting_id}.md")
    tmp_pdf = Path.join(System.tmp_dir!(), "meeting_#{meeting_id}.pdf")

    File.write!(tmp_md, markdown)

    case System.cmd(
           "pandoc",
           [tmp_md, "--pdf-engine=weasyprint", "--output", tmp_pdf, "--metadata", "lang=pt-BR"],
           stderr_to_stdout: true
         ) do
      {_, 0} ->
        File.rm(tmp_md)
        {:ok, tmp_pdf}

      {err, code} ->
        File.rm(tmp_md)
        {:error, "pandoc exited #{code}: #{err}"}
    end
  end
end

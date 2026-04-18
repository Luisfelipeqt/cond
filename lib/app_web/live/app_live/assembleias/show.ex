defmodule AppWeb.AppLive.Assembleias.Show do
  use AppWeb, :live_view

  alias App.Assembly
  alias App.Assembly.AgendaItem
  alias App.Condo
  alias App.Storage

  @tabs ~w(pauta presenca deliberacoes ata)

  @impl true
  def mount(%{"condo_id" => condo_id, "id" => id}, _session, socket) do
    meeting = Assembly.get_meeting!(id)
    quorum = Assembly.calculate_quorum(meeting)
    units = Condo.list_units_for_condo(condo_id)

    Phoenix.PubSub.subscribe(App.PubSub, "meeting:#{id}")

    socket
    |> assign(:condo_id, condo_id)
    |> assign(:condo, meeting.condo)
    |> assign(:meeting, meeting)
    |> assign(:quorum, quorum)
    |> assign(:units, units)
    |> assign(:tab, "pauta")
    |> assign(:agenda_item_form, nil)
    |> assign(:attendance_form, nil)
    |> assign(:summary_generating, false)
    |> assign(:page_title, meeting.title)
    |> allow_upload(:cartorio_doc, accept: ~w(.pdf), max_entries: 1, max_file_size: 20_000_000)
    |> ok()
  end

  @impl true
  def handle_params(params, _uri, socket) do
    tab = params |> Map.get("tab", "pauta") |> then(&if &1 in @tabs, do: &1, else: "pauta")

    socket
    |> assign(:tab, tab)
    |> noreply()
  end

  # ── Pauta ──────────────────────────────────────────────────────────────────

  @impl true
  def handle_event("new_agenda_item", _params, socket) do
    form =
      %AgendaItem{}
      |> Assembly.change_agenda_item()
      |> to_form()

    socket |> assign(:agenda_item_form, form) |> noreply()
  end

  def handle_event("cancel_agenda_item", _params, socket) do
    socket |> assign(:agenda_item_form, nil) |> noreply()
  end

  def handle_event("validate_agenda_item", %{"agenda_item" => params}, socket) do
    form =
      %AgendaItem{}
      |> Assembly.change_agenda_item(params)
      |> Map.put(:action, :validate)
      |> to_form()

    socket |> assign(:agenda_item_form, form) |> noreply()
  end

  def handle_event("save_agenda_item", %{"agenda_item" => params}, socket) do
    meeting = socket.assigns.meeting

    case Assembly.add_agenda_item(meeting, params) do
      {:ok, _item} ->
        meeting = Assembly.get_meeting!(meeting.id)

        socket
        |> assign(:meeting, meeting)
        |> assign(:agenda_item_form, nil)
        |> put_flash(:info, "Item adicionado à pauta.")
        |> noreply()

      {:error, changeset} ->
        socket |> assign(:agenda_item_form, to_form(changeset)) |> noreply()
    end
  end

  def handle_event("remove_agenda_item", %{"id" => id}, socket) do
    item = Enum.find(socket.assigns.meeting.agenda_items, &(&1.id == id))

    case Assembly.remove_agenda_item(item) do
      {:ok, _} ->
        meeting = Assembly.get_meeting!(socket.assigns.meeting.id)
        socket |> assign(:meeting, meeting) |> noreply()

      {:error, _} ->
        socket |> put_flash(:error, "Não foi possível remover o item.") |> noreply()
    end
  end

  # ── Presença ───────────────────────────────────────────────────────────────

  def handle_event("open_attendance_form", _params, socket) do
    socket |> assign(:attendance_form, to_form(%{"unit_id" => ""})) |> noreply()
  end

  def handle_event("cancel_attendance_form", _params, socket) do
    socket |> assign(:attendance_form, nil) |> noreply()
  end

  def handle_event("save_attendance", %{"attendance" => params}, socket) do
    meeting = socket.assigns.meeting
    user_id = socket.assigns.current_scope.user.id

    attrs =
      params
      |> Map.put("meeting_id", meeting.id)
      |> Map.put("user_id", user_id)
      |> Map.put("signed_at", DateTime.utc_now())

    case Assembly.record_attendance(attrs) do
      {:ok, _} ->
        meeting = Assembly.get_meeting!(meeting.id)
        quorum = Assembly.calculate_quorum(meeting)

        socket
        |> assign(:meeting, meeting)
        |> assign(:quorum, quorum)
        |> assign(:attendance_form, nil)
        |> put_flash(:info, "Presença registrada.")
        |> noreply()

      {:error, %Ecto.Changeset{} = cs} ->
        msg =
          cs.errors
          |> Keyword.get(:unit_id, {"Erro ao registrar presença.", []})
          |> elem(0)

        socket |> put_flash(:error, msg) |> noreply()
    end
  end

  # ── Deliberações ───────────────────────────────────────────────────────────

  def handle_event("save_resolution", %{"resolution" => params}, socket) do
    item_id = params["agenda_item_id"]
    item = Enum.find(socket.assigns.meeting.agenda_items, &(&1.id == item_id))

    case Assembly.record_resolution(item, params) do
      {:ok, _} ->
        meeting = Assembly.get_meeting!(socket.assigns.meeting.id)

        socket
        |> assign(:meeting, meeting)
        |> put_flash(:info, "Deliberação registrada.")
        |> noreply()

      {:error, changeset} ->
        socket |> put_flash(:error, "Erro: #{inspect(changeset.errors)}") |> noreply()
    end
  end

  # ── Transição de status ────────────────────────────────────────────────────

  def handle_event("advance_status", _params, socket) do
    next = next_status(socket.assigns.meeting.status)

    case Assembly.transition_meeting(socket.assigns.meeting, next) do
      {:ok, meeting} ->
        quorum = Assembly.calculate_quorum(meeting)

        socket
        |> assign(:meeting, meeting)
        |> assign(:quorum, quorum)
        |> put_flash(:info, "Status atualizado para «#{status_label(next)}».")
        |> noreply()

      {:error, changeset} ->
        msg = changeset.errors |> Keyword.get(:status, {"Erro desconhecido", []}) |> elem(0)
        socket |> put_flash(:error, msg) |> noreply()
    end
  end

  def handle_event("noop", _params, socket), do: noreply(socket)

  # ── Documento de cartório ──────────────────────────────────────────────────

  def handle_event("upload_cartorio_doc", _params, socket) do
    meeting = socket.assigns.meeting
    condo_id = socket.assigns.condo_id

    result =
      consume_uploaded_entries(socket, :cartorio_doc, fn %{path: path}, entry ->
        ext = Path.extname(entry.client_name)
        key = "meetings/#{condo_id}/#{meeting.id}/cartorio#{ext}"
        Storage.upload(path, key, "application/pdf")
      end)

    case result do
      [{:ok, url}] ->
        {:ok, updated} = Assembly.attach_document(meeting, url)

        socket
        |> assign(:meeting, updated)
        |> put_flash(:info, "Documento de cartório enviado com sucesso.")
        |> noreply()

      _ ->
        socket |> put_flash(:error, "Falha ao enviar o documento.") |> noreply()
    end
  end

  # ── Resumo AI ──────────────────────────────────────────────────────────────

  def handle_event("generate_summary", _params, socket) do
    meeting = socket.assigns.meeting

    %{"meeting_id" => meeting.id}
    |> App.Workers.GenerateSummary.new()
    |> Oban.insert()

    socket
    |> assign(:summary_generating, true)
    |> put_flash(:info, "Gerando resumo... Você será notificado quando estiver pronto.")
    |> noreply()
  end

  @impl true
  def handle_info({:summary_ready, updated_meeting}, socket) do
    socket
    |> assign(:meeting, updated_meeting)
    |> assign(:summary_generating, false)
    |> put_flash(:info, "Resumo gerado com sucesso!")
    |> noreply()
  end

  # ── Helpers (usados no template) ───────────────────────────────────────────

  def meeting_type_label("ago"), do: "AGO"
  def meeting_type_label("age"), do: "AGE"
  def meeting_type_label("council"), do: "Conselho"
  def meeting_type_label(_), do: "Outro"

  def meeting_status_label("scheduled"), do: "Agendada"
  def meeting_status_label("held"), do: "Realizada"
  def meeting_status_label("minutes_draft"), do: "Ata em rascunho"
  def meeting_status_label("minutes_approved"), do: "Ata aprovada"
  def meeting_status_label("registered"), do: "Registrada"
  def meeting_status_label("cancelled"), do: "Cancelada"
  def meeting_status_label(_), do: "—"

  def status_label(status), do: meeting_status_label(status)

  def meeting_status_class("scheduled"), do: "badge-info"
  def meeting_status_class("held"), do: "badge-warning"
  def meeting_status_class("minutes_draft"), do: "badge-warning"
  def meeting_status_class("minutes_approved"), do: "badge-success"
  def meeting_status_class("registered"), do: "badge-neutral"
  def meeting_status_class("cancelled"), do: "badge-error"
  def meeting_status_class(_), do: "badge-ghost"

  def quorum_type_label("simple"), do: "Maioria simples"
  def quorum_type_label("absolute"), do: "Maioria absoluta (> 50%)"
  def quorum_type_label("two_thirds"), do: "Dois terços (> 66%)"
  def quorum_type_label("unanimous"), do: "Unanimidade"
  def quorum_type_label(_), do: "—"

  def item_type_label("informational"), do: "Informativo"
  def item_type_label("deliberative"), do: "Deliberativo"
  def item_type_label(_), do: "—"

  def item_status_label("pending"), do: "Pendente"
  def item_status_label("discussed"), do: "Discutido"
  def item_status_label("resolved"), do: "Resolvido"
  def item_status_label("tabled"), do: "Adiado"
  def item_status_label(_), do: "—"

  def resolution_result_label("approved"), do: "Aprovado"
  def resolution_result_label("rejected"), do: "Rejeitado"
  def resolution_result_label("tabled"), do: "Adiado"
  def resolution_result_label("no_quorum"), do: "Sem quórum"
  def resolution_result_label(_), do: "—"

  def resolution_result_class("approved"), do: "badge-success"
  def resolution_result_class("rejected"), do: "badge-error"
  def resolution_result_class("tabled"), do: "badge-warning"
  def resolution_result_class("no_quorum"), do: "badge-neutral"
  def resolution_result_class(_), do: "badge-ghost"

  defp next_status("scheduled"), do: "held"
  defp next_status("held"), do: "minutes_draft"
  defp next_status("minutes_draft"), do: "minutes_approved"
  defp next_status("minutes_approved"), do: "registered"
  defp next_status(s), do: s
end

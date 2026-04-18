defmodule App.Assembly do
  @moduledoc """
  Contexto de Gestão de Assembleias e Atas.

  Responsável pelo ciclo de vida completo de reuniões/assembleias de condomínio:
    - Agendamento e convocação (AGO, AGE, Conselho)
    - Controle de pauta (agenda_items)
    - Registro de presença e procurações
    - Cálculo de quórum por fração ideal
    - Registro de deliberações e resultados
    - Ciclo de aprovação da ata
  """

  import Ecto.Query
  alias App.Repo
  alias App.Assembly.{Meeting, AgendaItem, Resolution, Attendance, Proxy}
  alias App.Condo.Unit

  # ---------------------------------------------------------------------------
  # Reuniões
  # ---------------------------------------------------------------------------

  @doc "Lista todas as reuniões de um condomínio, ordenadas pela data agendada."
  def list_meetings(condo_id) do
    Meeting
    |> where([m], m.condo_id == ^condo_id)
    |> order_by([m], desc: m.scheduled_at)
    |> Repo.all()
  end

  @doc "Busca uma reunião pelo id, levantando exceção se não encontrada."
  def get_meeting!(id) do
    agenda_items_query = from a in AgendaItem, order_by: [asc: a.order]

    Meeting
    |> Repo.get!(id)
    |> Repo.preload([
      :condo,
      :created_by,
      agenda_items: {agenda_items_query, :resolution},
      attendances: [:unit, :user],
      proxies: [:grantor_unit, :grantor_user, :grantee_user]
    ])
  end

  @doc "Cria uma nova reunião."
  def create_meeting(attrs) do
    %Meeting{}
    |> Meeting.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Atualiza os dados de uma reunião."
  def update_meeting(%Meeting{} = meeting, attrs) do
    meeting
    |> Meeting.changeset(attrs)
    |> Repo.update()
  end

  @doc "Avança o status de uma reunião para o próximo estado no ciclo de vida."
  def transition_meeting(%Meeting{} = meeting, new_status) do
    meeting
    |> Meeting.status_transition_changeset(new_status)
    |> Repo.update()
  end

  @doc "Retorna um changeset para forms de criação/edição de reunião."
  def change_meeting(attrs \\ %{}) do
    Meeting.changeset(attrs)
  end

  def change_meeting(%Meeting{} = meeting, attrs) do
    Meeting.changeset(meeting, attrs)
  end

  @doc "Salva a URL do documento de cartório na reunião."
  def attach_document(%Meeting{} = meeting, url) do
    meeting
    |> Meeting.changeset(%{registered_document_url: url})
    |> Repo.update()
  end

  @doc "Salva URL do PDF resumido e hash de conteúdo após geração via AI."
  def save_summary(%Meeting{} = meeting, pdf_url, content_hash) do
    meeting
    |> Meeting.changeset(%{
      summary_pdf_url: pdf_url,
      summary_content_hash: content_hash,
      summary_generated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
    |> Repo.update()
  end

  @doc "SHA-256 do conteúdo relevante da ata — usado para cache do resumo AI."
  def content_hash(%Meeting{} = meeting) do
    data =
      Jason.encode!(%{
        title: meeting.title,
        notes: meeting.notes,
        location: meeting.location,
        agenda_items:
          Enum.map(meeting.agenda_items, fn item ->
            %{
              title: item.title,
              description: item.description,
              status: item.status,
              resolution:
                if item.resolution do
                  %{
                    result: item.resolution.result,
                    votes_for: item.resolution.votes_for,
                    votes_against: item.resolution.votes_against,
                    votes_abstain: item.resolution.votes_abstain
                  }
                end
            }
          end),
        attendances_count: length(meeting.attendances)
      })

    :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
  end

  # ---------------------------------------------------------------------------
  # Pauta (AgendaItems)
  # ---------------------------------------------------------------------------

  @doc "Adiciona um item à pauta de uma reunião."
  def add_agenda_item(%Meeting{} = meeting, attrs) do
    attrs = Map.put(attrs, "meeting_id", meeting.id)

    %AgendaItem{}
    |> AgendaItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Atualiza um item de pauta."
  def update_agenda_item(%AgendaItem{} = item, attrs) do
    item
    |> AgendaItem.changeset(attrs)
    |> Repo.update()
  end

  @doc "Remove um item de pauta."
  def remove_agenda_item(%AgendaItem{} = item) do
    Repo.delete(item)
  end

  @doc """
  Reordena os itens de pauta de uma reunião.
  Recebe uma lista de IDs na nova ordem desejada e atualiza o campo `order`.
  """
  def reorder_agenda_items(%Meeting{} = meeting, ordered_ids) do
    ordered_ids
    |> Enum.with_index(1)
    |> Enum.reduce(Ecto.Multi.new(), fn {id, position}, multi ->
      Ecto.Multi.update_all(
        multi,
        {:reorder, id},
        from(a in AgendaItem,
          where: a.id == ^id and a.meeting_id == ^meeting.id
        ),
        set: [order: position]
      )
    end)
    |> Repo.transaction()
  end

  @doc "Retorna um changeset para forms de item de pauta."
  def change_agenda_item(%AgendaItem{} = item \\ %AgendaItem{}, attrs \\ %{}) do
    AgendaItem.changeset(item, attrs)
  end

  # ---------------------------------------------------------------------------
  # Presenças
  # ---------------------------------------------------------------------------

  @doc "Registra a presença de uma unidade na reunião."
  def record_attendance(attrs) do
    %Attendance{}
    |> Attendance.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Remove o registro de presença de uma unidade."
  def remove_attendance(%Attendance{} = attendance) do
    Repo.delete(attendance)
  end

  @doc "Lista todas as presenças de uma reunião com preloads de unidade e usuário."
  def list_attendances(%Meeting{} = meeting) do
    Attendance
    |> where([a], a.meeting_id == ^meeting.id)
    |> preload([:unit, :user, :proxy])
    |> Repo.all()
  end

  # ---------------------------------------------------------------------------
  # Procurações
  # ---------------------------------------------------------------------------

  @doc "Registra uma procuração para uma reunião."
  def register_proxy(attrs) do
    %Proxy{}
    |> Proxy.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Valida uma procuração (confirma que o documento foi conferido)."
  def validate_proxy(%Proxy{} = proxy, validated_by_id) do
    proxy
    |> Proxy.validate_changeset(validated_by_id)
    |> Repo.update()
  end

  @doc "Lista todas as procurações de uma reunião."
  def list_proxies(%Meeting{} = meeting) do
    Proxy
    |> where([p], p.meeting_id == ^meeting.id)
    |> preload([:grantor_unit, :grantor_user, :grantee_user, :validated_by])
    |> Repo.all()
  end

  # ---------------------------------------------------------------------------
  # Deliberações
  # ---------------------------------------------------------------------------

  @doc "Registra o resultado de uma deliberação de um item de pauta."
  def record_resolution(%AgendaItem{} = item, attrs) do
    attrs = Map.put(attrs, "agenda_item_id", item.id)

    %Resolution{}
    |> Resolution.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Atualiza uma deliberação já registrada."
  def update_resolution(%Resolution{} = resolution, attrs) do
    resolution
    |> Resolution.changeset(attrs)
    |> Repo.update()
  end

  # ---------------------------------------------------------------------------
  # Quórum
  # ---------------------------------------------------------------------------

  @doc """
  Calcula o quórum presente em uma reunião com base nas frações ideais das unidades.

  Retorna um mapa com:
    - `total_fraction` — soma das frações das unidades presentes (0.0 a 1.0)
    - `total_units_present` — número de unidades presentes
    - `total_units` — total de unidades do condomínio
    - `quorum_percentage` — percentual do total do condo (0.0 a 100.0)
    - `has_simple_quorum` — maioria simples dos presentes (> 50% das frações presentes)
    - `has_absolute_quorum` — maioria absoluta (presença de > 50% das frações do condo)
  """
  def calculate_quorum(%Meeting{} = meeting) do
    attendances = list_attendances(meeting)

    unit_ids = Enum.map(attendances, & &1.unit_id)

    units_with_fractions =
      Unit
      |> where([u], u.id in ^unit_ids)
      |> select([u], u.fraction)
      |> Repo.all()

    total_fraction =
      units_with_fractions
      |> Enum.reject(&is_nil/1)
      |> Enum.reduce(Decimal.new("0"), &Decimal.add/2)

    total_units_in_condo =
      Unit
      |> where([u], u.condo_id == ^meeting.condo_id)
      |> Repo.aggregate(:count, :id)

    quorum_percentage =
      total_fraction
      |> Decimal.mult(Decimal.new("100"))
      |> Decimal.round(2)

    %{
      total_fraction: total_fraction,
      total_units_present: length(attendances),
      total_units: total_units_in_condo,
      quorum_percentage: quorum_percentage,
      has_simple_quorum: Decimal.gt?(total_fraction, Decimal.new("0.5")),
      has_absolute_quorum: Decimal.gt?(total_fraction, Decimal.new("0.5"))
    }
  end

  @doc """
  Verifica se uma reunião atingiu o quórum exigido pelo seu `quorum_type`.
  """
  def has_required_quorum?(%Meeting{} = meeting) do
    %{total_fraction: fraction} = calculate_quorum(meeting)

    case meeting.quorum_type do
      "simple" -> Decimal.gt?(fraction, Decimal.new("0"))
      "absolute" -> Decimal.gt?(fraction, Decimal.new("0.5"))
      "two_thirds" -> Decimal.gt?(fraction, Decimal.new("0.6667"))
      "unanimous" -> Decimal.eq?(fraction, Decimal.new("1.0"))
      _ -> false
    end
  end
end

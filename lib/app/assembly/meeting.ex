defmodule App.Assembly.Meeting do
  use App.Schema
  import Ecto.Changeset
  import App.Utils

  @schema_prefix "assembly"

  @types ~w(ago age council other)
  @statuses ~w(scheduled held minutes_draft minutes_approved registered cancelled)
  @quorum_types ~w(simple absolute two_thirds unanimous)

  schema "meetings" do
    field :title, :string
    field :type, :string
    field :status, :string, default: "scheduled"
    field :scheduled_at, :utc_datetime
    field :held_at, :utc_datetime
    field :location, :string
    field :second_call_minutes, :integer, default: 30
    field :quorum_type, :string, default: "simple"
    field :notice_sent_at, :utc_datetime
    field :convocation_text, :string
    field :notes, :string
    field :registered_document_url, :string
    field :summary_pdf_url, :string
    field :summary_content_hash, :string
    field :summary_generated_at, :utc_datetime

    belongs_to :condo, App.Condo.Condo
    belongs_to :created_by, App.Accounts.User

    has_many :agenda_items, App.Assembly.AgendaItem, foreign_key: :meeting_id
    has_many :attendances, App.Assembly.Attendance, foreign_key: :meeting_id
    has_many :proxies, App.Assembly.Proxy, foreign_key: :meeting_id

    timestamps(type: :utc_datetime)
  end

  def changeset(attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = meeting, attrs) do
    meeting
    |> cast(attrs, [
      :condo_id,
      :created_by_id,
      :title,
      :type,
      :status,
      :scheduled_at,
      :held_at,
      :location,
      :second_call_minutes,
      :quorum_type,
      :notice_sent_at,
      :convocation_text,
      :notes,
      :registered_document_url,
      :summary_pdf_url,
      :summary_content_hash,
      :summary_generated_at
    ])
    |> validate_required([:condo_id, :created_by_id, :title, :type, :scheduled_at],
      message: "obrigatório"
    )
    |> validate_inclusion(:type, @types, message: "tipo inválido")
    |> validate_inclusion(:status, @statuses, message: "status inválido")
    |> validate_inclusion(:quorum_type, @quorum_types, message: "tipo de quórum inválido")
    |> validate_length(:title, min: 4, max: 200, message: "mínimo 4 caracteres")
    |> validate_number(:second_call_minutes,
      greater_than_or_equal_to: 0,
      message: "deve ser zero ou maior"
    )
    |> update_change(:title, &normalize/1)
    |> update_change(:location, &normalize/1)
    |> update_change(:convocation_text, &String.trim/1)
    |> update_change(:notes, &String.trim/1)
    |> foreign_key_constraint(:condo_id)
    |> foreign_key_constraint(:created_by_id)
  end

  def status_transition_changeset(meeting, new_status) do
    meeting
    |> change(status: new_status)
    |> validate_inclusion(:status, @statuses)
    |> validate_status_transition(meeting.status, new_status)
  end

  defp validate_status_transition(changeset, from, to) do
    valid_transitions = %{
      "scheduled" => ~w(held cancelled),
      "held" => ~w(minutes_draft cancelled),
      "minutes_draft" => ~w(minutes_approved),
      "minutes_approved" => ~w(registered),
      "registered" => [],
      "cancelled" => []
    }

    allowed = Map.get(valid_transitions, from, [])

    if to in allowed do
      changeset
    else
      add_error(changeset, :status, "transição inválida de '#{from}' para '#{to}'")
    end
  end
end

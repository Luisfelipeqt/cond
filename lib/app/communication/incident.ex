defmodule App.Communication.Incident do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "communication"
  @categories ~w(noise leak security maintenance other)
  @statuses ~w(open in_progress resolved cancelled)

  schema "incidents" do
    field :title, :string
    field :description, :string
    field :category, :string
    field :status, :string, default: "open"
    field :resolved_at, :utc_datetime

    belongs_to :condo, App.Condo.Condo
    belongs_to :user, App.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:condo_id, :user_id, :title, :description, :category, :status])
    |> validate_required([:condo_id, :user_id, :title, :description])
    |> validate_inclusion(:category, @categories)
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:condo_id)
    |> foreign_key_constraint(:user_id)
  end

  def resolve_changeset(incident) do
    change(incident,
      status: "resolved",
      resolved_at: DateTime.utc_now(:second)
    )
  end
end

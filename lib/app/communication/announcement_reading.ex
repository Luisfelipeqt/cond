defmodule App.Communication.AnnouncementReading do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "communication"
  schema "announcement_readings" do
    field :read_at, :utc_datetime

    belongs_to :announcement, App.Communication.Announcement
    belongs_to :user, App.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:announcement_id, :user_id, :read_at])
    |> validate_required([:announcement_id, :user_id, :read_at])
    |> unique_constraint([:announcement_id, :user_id])
    |> foreign_key_constraint(:announcement_id)
    |> foreign_key_constraint(:user_id)
  end
end

defmodule App.Communication.Announcement do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "communication"
  @types ~w(notice urgent meeting)

  schema "announcements" do
    field :title, :string
    field :body, :string
    field :type, :string, default: "notice"
    field :sent_at, :utc_datetime

    belongs_to :condo, App.Condo.Condo
    belongs_to :user, App.Accounts.User

    has_many :readings, App.Communication.AnnouncementReading, foreign_key: :announcement_id

    timestamps(type: :utc_datetime)
  end

  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:condo_id, :user_id, :title, :body, :type])
    |> validate_required([:condo_id, :user_id, :title, :body])
    |> validate_inclusion(:type, @types)
    |> foreign_key_constraint(:condo_id)
    |> foreign_key_constraint(:user_id)
  end

  def send_changeset(announcement) do
    change(announcement, sent_at: DateTime.utc_now(:second))
  end
end

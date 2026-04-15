defmodule App.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements, prefix: "communication") do
      add :condo_id,
          references(:condominiums, type: :binary_id, prefix: "condo"),
          null: false

      add :user_id,
          references(:users, type: :binary_id, prefix: "identity", on_delete: :restrict),
          null: false

      add :title, :string, null: false
      add :body, :text, null: false
      # "notice" | "urgent" | "meeting"
      add :type, :string, null: false, default: "notice"
      add :sent_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:announcements, [:condo_id], prefix: "communication")
    create index(:announcements, [:user_id], prefix: "communication")
  end
end

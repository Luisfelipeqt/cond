defmodule App.Repo.Migrations.CreateAnnouncementReadings do
  use Ecto.Migration

  def change do
    create table(:announcement_readings,  prefix: "communication") do


      add :announcement_id,
          references(:announcements, type: :binary_id, prefix: "communication"),
          null: false

      add :user_id,
          references(:users, type: :binary_id, prefix: "identity", on_delete: :delete_all),
          null: false

      add :read_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:announcement_readings, [:announcement_id], prefix: "communication")

    create unique_index(:announcement_readings, [:announcement_id, :user_id],
             prefix: "communication"
           )
  end
end

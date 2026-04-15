defmodule App.Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def change do
    create table(:incidents, prefix: "communication") do
      add :condo_id,
          references(:condominiums, type: :binary_id, prefix: "condo"),
          null: false

      add :user_id,
          references(:users, type: :binary_id, prefix: "identity", on_delete: :restrict),
          null: false

      add :title, :string, null: false
      add :description, :text, null: false
      # "noise" | "leak" | "security" | "maintenance" | "other"
      add :category, :string
      # "open" | "in_progress" | "resolved" | "cancelled"
      add :status, :string, null: false, default: "open"
      add :resolved_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:incidents, [:condo_id], prefix: "communication")
    create index(:incidents, [:user_id], prefix: "communication")
    create index(:incidents, [:status], prefix: "communication")
  end
end

defmodule App.Repo.Migrations.CreateOrgMembers do
  use Ecto.Migration

  def change do
    create table(:org_members, prefix: "condo") do
      add :org_id,
          references(:organizations, type: :binary_id, prefix: "condo", on_delete: :delete_all),
          null: false

      add :user_id,
          references(:users, type: :binary_id, prefix: "identity", on_delete: :delete_all),
          null: false

      # "owner" | "admin" | "staff"
      add :role, :string, null: false, default: "owner"
      add :active, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end

    create index(:org_members, [:org_id], prefix: "condo")
    create index(:org_members, [:user_id], prefix: "condo")
    create unique_index(:org_members, [:org_id, :user_id], prefix: "condo")
  end
end

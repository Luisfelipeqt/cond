defmodule App.Repo.Migrations.CreateCondoMembers do
  use Ecto.Migration

  def change do
    create table(:condo_members, prefix: "condo") do
      add :user_id,
          references(:users, type: :binary_id, prefix: "identity", on_delete: :delete_all),
          null: false

      add :condo_id,
          references(:condominiums, type: :binary_id, prefix: "condo"),
          null: false

      add :unit_id,
          references(:units, type: :binary_id, prefix: "condo")

      # "owner" | "resident" | "board_member" | "manager"
      add :role, :string, null: false
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:condo_members, [:user_id], prefix: "condo")
    create index(:condo_members, [:condo_id], prefix: "condo")
    create unique_index(:condo_members, [:user_id, :condo_id], prefix: "condo")
  end
end

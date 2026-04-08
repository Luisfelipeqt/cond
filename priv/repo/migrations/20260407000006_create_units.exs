defmodule App.Repo.Migrations.CreateUnits do
  use Ecto.Migration

  def change do
    create table(:units,  prefix: "condo") do


      add :condo_id,
          references(:condominiums, type: :binary_id, prefix: "condo"),
          null: false

      add :number, :string, null: false
      add :block, :string
      # "apartment" | "house" | "commercial" | "parking"
      add :type, :string

      timestamps(type: :utc_datetime)
    end

    create index(:units, [:condo_id], prefix: "condo")
    create unique_index(:units, [:condo_id, :block, :number], prefix: "condo")
  end
end

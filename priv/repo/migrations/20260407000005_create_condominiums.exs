defmodule App.Repo.Migrations.CreateCondominiums do
  use Ecto.Migration

  def change do
    create table(:condominiums,  prefix: "condo") do


      add :org_id,
          references(:organizations, type: :binary_id, prefix: "condo"),
          null: false

      add :name, :string, null: false
      add :cnpj, :string
      add :total_units, :integer

      # Address
      add :street, :string
      add :street_number, :string
      add :complement, :string
      add :neighborhood, :string
      add :city, :string
      add :state, :string
      add :zip_code, :string

      timestamps(type: :utc_datetime)
    end

    create index(:condominiums, [:org_id], prefix: "condo")
    create unique_index(:condominiums, [:cnpj], prefix: "condo", where: "cnpj IS NOT NULL")
  end
end

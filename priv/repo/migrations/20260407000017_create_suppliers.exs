defmodule App.Repo.Migrations.CreateSuppliers do
  use Ecto.Migration

  def change do
    create table(:suppliers, prefix: "quotation") do
      add :org_id,
          references(:organizations, type: :binary_id, prefix: "condo"),
          null: false

      add :name, :string, null: false
      add :cnpj, :string
      add :email, :string, null: false
      add :phone, :string
      add :category, :string
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:suppliers, [:org_id], prefix: "quotation")

    create unique_index(:suppliers, [:org_id, :cnpj],
             prefix: "quotation",
             where: "cnpj IS NOT NULL"
           )
  end
end

defmodule App.Repo.Migrations.CreateDocumentTemplates do
  use Ecto.Migration

  def change do
    create table(:document_templates,  prefix: "documents") do


      add :org_id,
          references(:organizations, type: :binary_id, prefix: "condo"),
          null: false

      add :name, :string, null: false
      # "minutes" | "financial_report" | "quote" | "budget" | "notice"
      add :type, :string, null: false
      # JSON: [{field, label, type, required}]
      add :fields_schema, :map, null: false, default: %{}
      add :base_file, :string
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:document_templates, [:org_id], prefix: "documents")
    create index(:document_templates, [:type], prefix: "documents")
  end
end

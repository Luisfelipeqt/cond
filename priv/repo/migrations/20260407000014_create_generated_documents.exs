defmodule App.Repo.Migrations.CreateGeneratedDocuments do
  use Ecto.Migration

  def change do
    create table(:generated_documents, prefix: "documents") do
      add :condo_id,
          references(:condominiums, type: :binary_id, prefix: "condo"),
          null: false

      add :template_id,
          references(:document_templates, type: :binary_id, prefix: "documents"),
          null: false

      add :user_id,
          references(:users, type: :binary_id, prefix: "identity", on_delete: :restrict),
          null: false

      add :type, :string, null: false
      # JSON filled by the user, or {"quote_request_id": "..."} for quotes
      add :input_data, :map, null: false, default: %{}
      # "pending" | "processing" | "completed" | "error"
      add :status, :string, null: false, default: "pending"

      timestamps(type: :utc_datetime)
    end

    create index(:generated_documents, [:condo_id], prefix: "documents")
    create index(:generated_documents, [:template_id], prefix: "documents")
    create index(:generated_documents, [:user_id], prefix: "documents")
    create index(:generated_documents, [:status], prefix: "documents")
  end
end

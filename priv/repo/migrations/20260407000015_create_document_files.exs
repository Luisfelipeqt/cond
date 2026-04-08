defmodule App.Repo.Migrations.CreateDocumentFiles do
  use Ecto.Migration

  def change do
    create table(:document_files,  prefix: "documents") do


      add :document_id,
          references(:generated_documents, type: :binary_id, prefix: "documents"),
          null: false

      # "pptx" | "docx" | "pdf"
      add :format, :string, null: false
      add :storage_url, :string, null: false
      add :generated_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:document_files, [:document_id], prefix: "documents")
    create unique_index(:document_files, [:document_id, :format], prefix: "documents")
  end
end

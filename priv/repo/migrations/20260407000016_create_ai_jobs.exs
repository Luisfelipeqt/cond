defmodule App.Repo.Migrations.CreateAiJobs do
  use Ecto.Migration

  def change do
    create table(:ai_jobs, prefix: "documents") do
      add :document_id,
          references(:generated_documents, type: :binary_id, prefix: "documents"),
          null: false

      add :llm_model, :string, null: false
      add :prompt, :text, null: false
      add :llm_response, :text
      add :tokens_used, :integer
      # "pending" | "running" | "completed" | "error"
      add :status, :string, null: false, default: "pending"
      add :executed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:ai_jobs, [:document_id], prefix: "documents")
    create index(:ai_jobs, [:status], prefix: "documents")
  end
end

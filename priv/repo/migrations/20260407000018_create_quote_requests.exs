defmodule App.Repo.Migrations.CreateQuoteRequests do
  use Ecto.Migration

  def change do
    create table(:quote_requests, prefix: "quotation") do
      add :condo_id,
          references(:condominiums, type: :binary_id, prefix: "condo"),
          null: false

      add :user_id,
          references(:users, type: :binary_id, prefix: "identity", on_delete: :restrict),
          null: false

      # Filled when the request is closed and AI generates the comparison map
      add :document_id,
          references(:generated_documents, type: :binary_id, prefix: "documents")

      add :description, :string, null: false
      # "draft" | "sent" | "receiving" | "closed" | "approved"
      add :status, :string, null: false, default: "draft"
      add :response_deadline, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:quote_requests, [:condo_id], prefix: "quotation")
    create index(:quote_requests, [:user_id], prefix: "quotation")
    create index(:quote_requests, [:status], prefix: "quotation")
  end
end

defmodule App.Repo.Migrations.CreateQuoteResponses do
  use Ecto.Migration

  def change do
    create table(:quote_responses,  prefix: "quotation") do


      add :quote_request_id,
          references(:quote_requests, type: :binary_id, prefix: "quotation"),
          null: false

      # Null when supplier is ad-hoc (not registered)
      add :supplier_id,
          references(:suppliers, type: :binary_id, prefix: "quotation")

      # Used when supplier_id is null
      add :supplier_email, :string

      # UUID sent in the public link to the supplier
      add :access_token, :string, null: false
      add :expires_at, :utc_datetime, null: false
      # "pending" | "responded" | "declined"
      add :status, :string, null: false, default: "pending"
      add :notes, :text
      add :responded_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:quote_responses, [:quote_request_id], prefix: "quotation")
    create unique_index(:quote_responses, [:access_token], prefix: "quotation")
  end
end

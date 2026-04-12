defmodule App.Repo.Migrations.CreateQuoteResponseItems do
  use Ecto.Migration

  def change do
    create table(:quote_response_items, prefix: "quotation") do
      add :quote_response_id,
          references(:quote_responses, type: :binary_id, prefix: "quotation"),
          null: false

      add :quote_item_id,
          references(:quote_items, type: :binary_id, prefix: "quotation"),
          null: false

      # Stored as integer (cents) — Money.Ecto.Amount.Type in schema
      add :unit_price, :integer, null: false
      add :total_price, :integer, null: false
      add :delivery_deadline, :string
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:quote_response_items, [:quote_response_id], prefix: "quotation")

    create unique_index(:quote_response_items, [:quote_response_id, :quote_item_id],
             prefix: "quotation"
           )
  end
end

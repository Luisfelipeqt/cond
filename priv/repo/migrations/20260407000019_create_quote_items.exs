defmodule App.Repo.Migrations.CreateQuoteItems do
  use Ecto.Migration

  def change do
    create table(:quote_items,  prefix: "quotation") do


      add :quote_request_id,
          references(:quote_requests, type: :binary_id, prefix: "quotation"),
          null: false

      add :description, :string, null: false
      # "m2" | "unit" | "hour" | "kg" | "m" | "l"
      add :unit, :string
      add :quantity, :decimal, precision: 10, scale: 3

      timestamps(type: :utc_datetime)
    end

    create index(:quote_items, [:quote_request_id], prefix: "quotation")
  end
end

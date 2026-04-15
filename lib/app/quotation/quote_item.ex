defmodule App.Quotation.QuoteItem do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "quotation"
  @units ~w(m2 unit hour kg m l)

  schema "quote_items" do
    field :description, :string
    field :unit, :string
    field :quantity, :decimal

    belongs_to :quote_request, App.Quotation.QuoteRequest

    has_many :response_items, App.Quotation.QuoteResponseItem, foreign_key: :quote_item_id

    timestamps(type: :utc_datetime)
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:quote_request_id, :description, :unit, :quantity])
    |> validate_required([:quote_request_id, :description])
    |> validate_inclusion(:unit, @units)
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:quote_request_id)
  end
end

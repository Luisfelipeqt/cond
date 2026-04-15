defmodule App.Quotation.QuoteResponseItem do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "quotation"
  schema "quote_response_items" do
    field :unit_price, Money.Ecto.Amount.Type
    field :total_price, Money.Ecto.Amount.Type
    field :delivery_deadline, :string
    field :notes, :string

    belongs_to :quote_response, App.Quotation.QuoteResponse
    belongs_to :quote_item, App.Quotation.QuoteItem

    timestamps(type: :utc_datetime)
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :quote_response_id,
      :quote_item_id,
      :unit_price,
      :total_price,
      :delivery_deadline,
      :notes
    ])
    |> validate_required([:quote_response_id, :quote_item_id, :unit_price, :total_price])
    |> unique_constraint([:quote_response_id, :quote_item_id])
    |> foreign_key_constraint(:quote_response_id)
    |> foreign_key_constraint(:quote_item_id)
  end
end

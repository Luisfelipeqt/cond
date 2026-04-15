defmodule App.Quotation.QuoteResponse do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "quotation"
  @statuses ~w(pending responded declined)

  schema "quote_responses" do
    field :supplier_email, :string
    field :access_token, :string
    field :expires_at, :utc_datetime
    field :status, :string, default: "pending"
    field :notes, :string
    field :responded_at, :utc_datetime

    belongs_to :quote_request, App.Quotation.QuoteRequest
    # Null when supplier is ad-hoc
    belongs_to :supplier, App.Quotation.Supplier

    has_many :items, App.Quotation.QuoteResponseItem, foreign_key: :quote_response_id

    timestamps(type: :utc_datetime)
  end

  def changeset(response, attrs) do
    response
    |> cast(attrs, [
      :quote_request_id,
      :supplier_id,
      :supplier_email,
      :access_token,
      :expires_at,
      :status,
      :notes
    ])
    |> validate_required([:quote_request_id, :access_token, :expires_at])
    |> validate_inclusion(:status, @statuses)
    |> validate_supplier_or_email()
    |> unique_constraint(:access_token)
    |> foreign_key_constraint(:quote_request_id)
    |> foreign_key_constraint(:supplier_id)
  end

  def respond_changeset(response) do
    change(response, status: "responded", responded_at: DateTime.utc_now(:second))
  end

  defp validate_supplier_or_email(changeset) do
    if is_nil(get_field(changeset, :supplier_id)) and
         is_nil(get_field(changeset, :supplier_email)) do
      add_error(changeset, :supplier_email, "required when supplier is not registered")
    else
      changeset
    end
  end
end

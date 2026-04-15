defmodule App.Quotation.QuoteRequest do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "quotation"
  @statuses ~w(draft sent receiving closed approved)

  schema "quote_requests" do
    field :description, :string
    field :status, :string, default: "draft"
    field :response_deadline, :utc_datetime

    belongs_to :condo, App.Condo.Condo
    belongs_to :user, App.Accounts.User
    belongs_to :document, App.Documents.GeneratedDocument

    has_many :items, App.Quotation.QuoteItem, foreign_key: :quote_request_id
    has_many :responses, App.Quotation.QuoteResponse, foreign_key: :quote_request_id

    timestamps(type: :utc_datetime)
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:condo_id, :user_id, :description, :status, :response_deadline])
    |> validate_required([:condo_id, :user_id, :description])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:condo_id)
    |> foreign_key_constraint(:user_id)
  end
end

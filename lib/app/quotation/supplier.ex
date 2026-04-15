defmodule App.Quotation.Supplier do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "quotation"
  schema "suppliers" do
    field :name, :string
    field :cnpj, :string
    field :email, :string
    field :phone, :string
    field :category, :string
    field :active, :boolean, default: true

    belongs_to :org, App.Condo.Organization

    has_many :quote_responses, App.Quotation.QuoteResponse, foreign_key: :supplier_id

    timestamps(type: :utc_datetime)
  end

  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [:org_id, :name, :cnpj, :email, :phone, :category, :active])
    |> validate_required([:org_id, :name, :email])
    |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/, message: "must be a valid email")
    |> unique_constraint([:org_id, :cnpj])
    |> foreign_key_constraint(:org_id)
  end
end

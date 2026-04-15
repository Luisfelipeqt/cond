defmodule App.Condo.Condo do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "condo"
  schema "condominiums" do
    field :name, :string
    field :cnpj, :string
    field :total_units, :integer

    field :street, :string
    field :street_number, :string
    field :complement, :string
    field :neighborhood, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string

    belongs_to :org, App.Condo.Organization

    has_many :units, App.Condo.Unit
    has_many :members, App.Condo.Member
    has_many :common_areas, App.Condo.CommonArea
    has_many :generated_documents, App.Documents.GeneratedDocument, foreign_key: :condo_id
    has_many :quote_requests, App.Quotation.QuoteRequest, foreign_key: :condo_id
    has_many :meetings, App.Assembly.Meeting, foreign_key: :condo_id

    timestamps(type: :utc_datetime)
  end

  def changeset(condo, attrs) do
    condo
    |> cast(attrs, [
      :org_id,
      :name,
      :cnpj,
      :total_units,
      :street,
      :street_number,
      :complement,
      :neighborhood,
      :city,
      :state,
      :zip_code
    ])
    |> validate_required([:org_id, :name])
    |> unique_constraint(:cnpj)
    |> foreign_key_constraint(:org_id)
  end
end

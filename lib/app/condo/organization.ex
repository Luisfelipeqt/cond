defmodule App.Condo.Organization do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "condo"
  @types ~w(owner_managed property_manager)
  @plans ~w(basic professional enterprise)

  schema "organizations" do
    field :name, :string
    field :type, :string
    field :plan, :string, default: "basic"

    has_many :condominiums, App.Condo.Condo, foreign_key: :org_id
    has_many :document_templates, App.Documents.DocumentTemplate, foreign_key: :org_id
    has_many :suppliers, App.Quotation.Supplier, foreign_key: :org_id

    timestamps(type: :utc_datetime)
  end

  def changeset(org, attrs) do
    org
    |> cast(attrs, [:name, :type, :plan])
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, @types)
    |> validate_inclusion(:plan, @plans)
  end
end

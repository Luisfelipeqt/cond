defmodule App.Documents.DocumentTemplate do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "documents"
  @types ~w(minutes financial_report quote budget notice)

  schema "document_templates" do
    field :name, :string
    field :type, :string
    # JSON: [%{field: "title", label: "Meeting Title", type: "string", required: true}]
    field :fields_schema, :map, default: %{}
    field :base_file, :string
    field :active, :boolean, default: true

    belongs_to :org, App.Condo.Organization

    has_many :generated_documents, App.Documents.GeneratedDocument, foreign_key: :template_id

    timestamps(type: :utc_datetime)
  end

  def changeset(template, attrs) do
    template
    |> cast(attrs, [:org_id, :name, :type, :fields_schema, :base_file, :active])
    |> validate_required([:org_id, :name, :type])
    |> validate_inclusion(:type, @types)
    |> foreign_key_constraint(:org_id)
  end
end

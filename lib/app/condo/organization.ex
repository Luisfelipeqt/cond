defmodule App.Condo.Organization do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "condo"

  # professional_syndic → pessoa física, 5-30 condomínios, 1 usuário
  # property_manager    → administradora, N condomínios, N usuários
  # resident_syndic     → síndico morador, 1 condomínio, 1 usuário
  @types ~w(professional_syndic property_manager resident_syndic)
  @plans ~w(basic professional enterprise)

  schema "organizations" do
    field :name, :string
    field :type, :string
    field :plan, :string, default: "basic"
    field :onboarding_completed_at, :utc_datetime

    # Dados extras — obrigatórios apenas para property_manager
    field :cnpj, :string
    field :phone, :string
    field :street, :string
    field :street_number, :string
    field :complement, :string
    field :neighborhood, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string

    has_many :condominiums, App.Condo.Condo, foreign_key: :org_id
    has_many :members, App.Condo.OrgMember, foreign_key: :org_id
    has_many :document_templates, App.Documents.DocumentTemplate, foreign_key: :org_id
    has_many :suppliers, App.Quotation.Supplier, foreign_key: :org_id

    timestamps(type: :utc_datetime)
  end

  @doc "Changeset para criação no registro (mínimo)."
  def registration_changeset(org, attrs) do
    org
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type], message: "obrigatório")
    |> validate_length(:name, min: 2, max: 120, message: "mínimo 2 caracteres")
    |> validate_inclusion(:type, @types)
  end

  @doc "Changeset para dados complementares da administradora no onboarding."
  def property_manager_changeset(org, attrs) do
    org
    |> cast(attrs, [
      :cnpj,
      :phone,
      :street,
      :street_number,
      :complement,
      :neighborhood,
      :city,
      :state,
      :zip_code
    ])
    |> validate_required([:cnpj, :phone, :street, :street_number, :city, :state, :zip_code],
      message: "obrigatório"
    )
  end

  @doc "Marca o onboarding como concluído."
  def complete_onboarding_changeset(org) do
    change(org, onboarding_completed_at: DateTime.utc_now(:second))
  end

  @doc "Changeset genérico para edição."
  def changeset(org, attrs) do
    org
    |> cast(attrs, [:name, :type, :plan])
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, @types)
    |> validate_inclusion(:plan, @plans)
  end

  def types, do: @types

  def type_label("professional_syndic"), do: "Síndico profissional"
  def type_label("property_manager"), do: "Administradora"
  def type_label("resident_syndic"), do: "Síndico morador"
end

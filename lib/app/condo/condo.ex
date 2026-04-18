defmodule App.Condo.Condo do
  use App.Schema
  import Ecto.Changeset
  import App.Utils

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

  def changeset(attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = condo, attrs) do
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
    |> validate_required([:name], message: "obrigatório")
    |> validate_length(:name, min: 3, max: 120, message: "mínimo 3 caracteres")
    |> validate_number(:total_units, greater_than: 0, message: "deve ser maior que zero")
    |> update_change(:name, &normalize/1)
    |> update_change(:city, &normalize/1)
    |> update_change(:neighborhood, &normalize/1)
    |> update_change(:street, &normalize/1)
    |> update_change(:state, &upcase_state/1)
    |> update_change(:zip_code, &only_numbers/1)
    |> unique_constraint(:cnpj)
    |> foreign_key_constraint(:org_id)
  end

  defp upcase_state(nil), do: nil
  defp upcase_state(s), do: s |> String.trim() |> String.upcase()
end

defmodule App.Marketing.Contact do
  use App.Schema
  import App.Utils
  import Brcpfcnpj.Changeset
  @schema_prefix "marketing"

  schema "contacts" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :cpf, :string

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = contact, attrs) do
    contact
    |> cast(attrs, [:name, :email, :phone, :cpf])
    |> validate_required([:name, :email, :phone, :cpf],
      message: "obrigatório"
    )
    |> validate_length(:name, min: 2, max: 100, message: "mínimo 2 caracteres")
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/, message: "formato inválido")
    |> validate_length(:phone, min: 11, max: 15, message: "mínimo 10 dígitos")
    |> update_change(:email, &String.downcase/1)
    |> update_change(:name, &normalize/1)
    |> validate_cpf(:cpf)
    |> unique_constraint(:email,
      name: "marketing_contacts_email_index",
      message: "já cadastrado — em breve entraremos em contato"
    )
    |> unique_constraint(:cpf,
      name: "marketing_contacts_cpf_index",
      message: "já cadastrado — em breve entraremos em contato"
    )
  end
end

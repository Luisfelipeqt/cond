defmodule App.Marketing.Contact do
  use App.Schema

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
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/,
      message: "formato inválido"
    )
    |> normalize_cpf()
    |> validate_cpf_format()
    |> normalize_phone()
    |> validate_length(:phone, min: 10, max: 20, message: "mínimo 10 dígitos")
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email,
      name: "marketing_contacts_email_index",
      message: "já cadastrado — em breve entraremos em contato"
    )
    |> unique_constraint(:cpf,
      name: "marketing_contacts_cpf_index",
      message: "já cadastrado — em breve entraremos em contato"
    )
  end

  defp normalize_cpf(changeset) do
    update_change(changeset, :cpf, fn cpf ->
      String.replace(cpf, ~r/\D/, "")
    end)
  end

  defp validate_cpf_format(changeset) do
    validate_change(changeset, :cpf, fn :cpf, cpf ->
      cond do
        String.length(cpf) != 11 ->
          [cpf: "deve ter 11 dígitos"]

        cpf |> String.graphemes() |> Enum.uniq() |> length() == 1 ->
          [cpf: "inválido"]

        true ->
          []
      end
    end)
  end

  defp normalize_phone(changeset) do
    update_change(changeset, :phone, fn phone ->
      String.replace(phone, ~r/[^\d+]/, "")
    end)
  end
end

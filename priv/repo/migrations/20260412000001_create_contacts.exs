defmodule App.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, prefix: "marketing") do
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string, null: false
      add :cpf, :string, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:contacts, [:email], prefix: "marketing")
    create unique_index(:contacts, [:cpf], prefix: "marketing")
  end
end

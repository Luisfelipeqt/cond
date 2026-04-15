defmodule App.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, prefix: "marketing") do
      add :name, :string, size: 150, null: false
      add :email, :string, size: 254, null: false
      add :phone, :string, size: 15, null: false
      add :cpf, :char, size: 11, null: false
      add :contacted_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:contacts, [:email], prefix: "marketing")
    create unique_index(:contacts, [:cpf], prefix: "marketing")
  end
end

defmodule App.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations,  prefix: "condo") do

      add :name, :string, null: false
      # "owner_managed" | "property_manager"
      add :type, :string, null: false
      # "basic" | "professional" | "enterprise"
      add :plan, :string, null: false, default: "basic"

      timestamps(type: :utc_datetime)
    end
  end
end

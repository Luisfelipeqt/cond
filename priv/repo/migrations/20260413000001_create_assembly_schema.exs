defmodule App.Repo.Migrations.CreateAssemblySchema do
  use Ecto.Migration

  def up do
    execute "CREATE SCHEMA IF NOT EXISTS assembly"
  end

  def down do
    execute "DROP SCHEMA IF EXISTS assembly CASCADE"
  end
end

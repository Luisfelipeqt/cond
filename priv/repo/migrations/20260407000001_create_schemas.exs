defmodule App.Repo.Migrations.CreateSchemas do
  use Ecto.Migration

  def up do
    execute "CREATE SCHEMA IF NOT EXISTS identity"
    execute "CREATE SCHEMA IF NOT EXISTS condo"
    execute "CREATE SCHEMA IF NOT EXISTS communication"
    execute "CREATE SCHEMA IF NOT EXISTS documents"
    execute "CREATE SCHEMA IF NOT EXISTS quotation"
    execute "CREATE SCHEMA IF NOT EXISTS marketing"
  end

  def down do
    execute "DROP SCHEMA IF EXISTS quotation CASCADE"
    execute "DROP SCHEMA IF EXISTS documents CASCADE"
    execute "DROP SCHEMA IF EXISTS communication CASCADE"
    execute "DROP SCHEMA IF EXISTS condo CASCADE"
    execute "DROP SCHEMA IF EXISTS identity CASCADE"
    execute "DROP SCHEMA IF EXISTS marketing CASCADE"
  end
end

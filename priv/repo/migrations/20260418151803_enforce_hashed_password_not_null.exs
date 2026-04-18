defmodule App.Repo.Migrations.EnforceHashedPasswordNotNull do
  use Ecto.Migration

  def up do
    # Any user with NULL hashed_password gets a random unusable hash
    # (these users can only log in via magic link)
    execute """
    UPDATE identity.users
    SET hashed_password = 'LOCKED:' || encode(sha256(random()::text::bytea), 'hex')
    WHERE hashed_password IS NULL
    """

    alter table(:users, prefix: "identity") do
      modify :hashed_password, :string, null: false
    end
  end

  def down do
    alter table(:users, prefix: "identity") do
      modify :hashed_password, :string, null: true
    end
  end
end

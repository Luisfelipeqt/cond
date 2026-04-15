defmodule App.Repo.Migrations.CreateAttendances do
  use Ecto.Migration

  def change do
    create table(:attendances, prefix: "assembly") do
      add :meeting_id,
          references(:meetings, type: :binary_id, prefix: "assembly"),
          null: false

      # A unidade representada (proprietário ou inquilino)
      add :unit_id,
          references(:units, type: :binary_id, prefix: "condo"),
          null: false

      # Quem fisicamente compareceu (pode ser o próprio ou um procurador)
      add :user_id,
          references(:users, type: :binary_id, prefix: "identity"),
          null: false

      # Se compareceu por procuração, aponta para o registro da procuração
      add :proxy_id,
          references(:proxies, type: :binary_id, prefix: "assembly")

      # Momento em que assinou a lista de presença
      add :signed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:attendances, [:meeting_id], prefix: "assembly")
    create index(:attendances, [:unit_id], prefix: "assembly")

    # Uma unidade só pode ter uma presença por reunião
    create unique_index(:attendances, [:meeting_id, :unit_id], prefix: "assembly")
  end
end

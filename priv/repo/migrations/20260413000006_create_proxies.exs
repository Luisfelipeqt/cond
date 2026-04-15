defmodule App.Repo.Migrations.CreateProxies do
  use Ecto.Migration

  def change do
    create table(:proxies, prefix: "assembly") do
      add :meeting_id,
          references(:meetings, type: :binary_id, prefix: "assembly"),
          null: false

      # Unidade que outorgou a procuração
      add :grantor_unit_id,
          references(:units, type: :binary_id, prefix: "condo"),
          null: false

      # Condômino que outorgou
      add :grantor_user_id,
          references(:users, type: :binary_id, prefix: "identity"),
          null: false

      # Quem vai representar (procurador)
      add :grantee_user_id,
          references(:users, type: :binary_id, prefix: "identity"),
          null: false

      # Caminho do documento digitalizado da procuração
      add :document_path, :string

      # Se a procuração foi validada pela administração
      add :validated, :boolean, null: false, default: false

      add :validated_by_id,
          references(:users, type: :binary_id, prefix: "identity")

      add :validated_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:proxies, [:meeting_id], prefix: "assembly")
    create index(:proxies, [:grantee_user_id], prefix: "assembly")

    # Uma unidade só pode outorgar uma procuração por reunião
    create unique_index(:proxies, [:meeting_id, :grantor_unit_id], prefix: "assembly")
  end
end

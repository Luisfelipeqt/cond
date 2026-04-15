defmodule App.Repo.Migrations.CreateMeetings do
  use Ecto.Migration

  def change do
    create table(:meetings, prefix: "assembly") do
      add :condo_id,
          references(:condominiums, type: :binary_id, prefix: "condo"),
          null: false

      add :created_by_id,
          references(:users, type: :binary_id, prefix: "identity"),
          null: false

      # Título formal: "1ª AGO de 2026 — Condomínio X"
      add :title, :string, null: false

      # ago | age | council | other
      add :type, :string, null: false

      # scheduled | held | minutes_draft | minutes_approved | registered | cancelled
      add :status, :string, null: false, default: "scheduled"

      # Data/hora planejada (convocação)
      add :scheduled_at, :utc_datetime, null: false

      # Data/hora real de início (preenchida ao realizar)
      add :held_at, :utc_datetime

      add :location, :string

      # Minutos de tolerância até segunda convocação (padrão: 30)
      add :second_call_minutes, :integer, default: 30

      # simple | absolute | two_thirds | unanimous
      add :quorum_type, :string, null: false, default: "simple"

      # Quando a convocação foi enviada aos condôminos
      add :notice_sent_at, :utc_datetime

      # Texto completo da convocação/edital
      add :convocation_text, :text

      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:meetings, [:condo_id], prefix: "assembly")
    create index(:meetings, [:created_by_id], prefix: "assembly")
    create index(:meetings, [:status], prefix: "assembly")
    create index(:meetings, [:scheduled_at], prefix: "assembly")
  end
end

defmodule App.Repo.Migrations.CreateAgendaItems do
  use Ecto.Migration

  def change do
    create table(:agenda_items, prefix: "assembly") do
      add :meeting_id,
          references(:meetings, type: :binary_id, prefix: "assembly"),
          null: false

      # Posição na pauta (1, 2, 3...)
      add :order, :integer, null: false

      add :title, :string, null: false
      add :description, :text

      # informational | deliberative
      add :item_type, :string, null: false, default: "deliberative"

      # pending | discussed | resolved | tabled
      add :status, :string, null: false, default: "pending"

      timestamps(type: :utc_datetime)
    end

    create index(:agenda_items, [:meeting_id], prefix: "assembly")
    create unique_index(:agenda_items, [:meeting_id, :order], prefix: "assembly")
  end
end

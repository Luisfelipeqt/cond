defmodule App.Repo.Migrations.CreateCommonAreas do
  use Ecto.Migration

  def change do
    create table(:common_areas, prefix: "condo") do
      add :condo_id,
          references(:condominiums, type: :binary_id, prefix: "condo"),
          null: false

      add :name, :string, null: false
      add :description, :text
      add :capacity, :integer
      add :active, :boolean, default: true, null: false
      add :opens_at, :time
      add :closes_at, :time
      add :max_daily_reservations, :integer
      add :min_advance_hours, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:common_areas, [:condo_id], prefix: "condo")
  end
end

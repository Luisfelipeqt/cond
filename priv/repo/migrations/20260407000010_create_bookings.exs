defmodule App.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings, prefix: "condo") do
      add :area_id,
          references(:common_areas, type: :binary_id, prefix: "condo"),
          null: false

      add :user_id,
          references(:users, type: :binary_id, prefix: "identity", on_delete: :restrict),
          null: false

      add :starts_at, :utc_datetime, null: false
      add :ends_at, :utc_datetime, null: false
      # "pending" | "confirmed" | "cancelled"
      add :status, :string, null: false, default: "pending"
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:bookings, [:area_id], prefix: "condo")
    create index(:bookings, [:user_id], prefix: "condo")
    create index(:bookings, [:starts_at, :ends_at], prefix: "condo")
  end
end

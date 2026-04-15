defmodule App.Repo.Migrations.AddFractionToUnits do
  use Ecto.Migration

  def change do
    alter table(:units, prefix: "condo") do
      # Fração ideal da unidade no condomínio (ex: 0.010000 = 1%).
      # A soma de todas as frações de um condomínio deve ser 1.0 (100%).
      add :fraction, :decimal, precision: 10, scale: 6
    end
  end
end

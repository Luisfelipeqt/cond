defmodule App.Repo.Migrations.CreateResolutions do
  use Ecto.Migration

  def change do
    create table(:resolutions, prefix: "assembly") do
      add :agenda_item_id,
          references(:agenda_items, type: :binary_id, prefix: "assembly"),
          null: false

      # approved | rejected | tabled | no_quorum
      add :result, :string, null: false

      # Contagem de votos (por unidade/condômino)
      add :votes_for, :integer, null: false, default: 0
      add :votes_against, :integer, null: false, default: 0
      add :votes_abstain, :integer, null: false, default: 0

      # Percentual de frações ideais correspondente a cada posição (0.0 a 1.0)
      add :fraction_for, :decimal, precision: 10, scale: 6, default: 0
      add :fraction_against, :decimal, precision: 10, scale: 6, default: 0
      add :fraction_abstain, :decimal, precision: 10, scale: 6, default: 0

      # Se o quórum legal foi atingido para esta deliberação
      add :quorum_achieved, :boolean, null: false, default: false

      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:resolutions, [:agenda_item_id], prefix: "assembly",
             name: "resolutions_agenda_item_id_index")
  end
end

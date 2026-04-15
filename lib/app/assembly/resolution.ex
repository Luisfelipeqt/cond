defmodule App.Assembly.Resolution do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "assembly"

  @results ~w(approved rejected tabled no_quorum)

  schema "resolutions" do
    field :result, :string
    field :votes_for, :integer, default: 0
    field :votes_against, :integer, default: 0
    field :votes_abstain, :integer, default: 0
    field :fraction_for, :decimal, default: Decimal.new("0")
    field :fraction_against, :decimal, default: Decimal.new("0")
    field :fraction_abstain, :decimal, default: Decimal.new("0")
    field :quorum_achieved, :boolean, default: false
    field :notes, :string

    belongs_to :agenda_item, App.Assembly.AgendaItem

    timestamps(type: :utc_datetime)
  end

  def changeset(resolution, attrs) do
    resolution
    |> cast(attrs, [
      :agenda_item_id,
      :result,
      :votes_for,
      :votes_against,
      :votes_abstain,
      :fraction_for,
      :fraction_against,
      :fraction_abstain,
      :quorum_achieved,
      :notes
    ])
    |> validate_required([:agenda_item_id, :result])
    |> validate_inclusion(:result, @results)
    |> validate_number(:votes_for, greater_than_or_equal_to: 0)
    |> validate_number(:votes_against, greater_than_or_equal_to: 0)
    |> validate_number(:votes_abstain, greater_than_or_equal_to: 0)
    |> unique_constraint(:agenda_item_id,
      message: "já existe uma deliberação para este item de pauta"
    )
    |> foreign_key_constraint(:agenda_item_id)
  end
end

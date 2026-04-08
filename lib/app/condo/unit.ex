defmodule App.Condo.Unit do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "condo"
  @types ~w(apartment house commercial parking)
  schema "units" do
    field :number, :string
    field :block, :string
    field :type, :string

    belongs_to :condo, App.Condo.Condo

    has_many :members, App.Condo.Member

    timestamps(type: :utc_datetime)
  end

  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:condo_id, :number, :block, :type])
    |> validate_required([:condo_id, :number])
    |> validate_inclusion(:type, @types)
    |> unique_constraint([:condo_id, :block, :number])
    |> foreign_key_constraint(:condo_id)
  end
end

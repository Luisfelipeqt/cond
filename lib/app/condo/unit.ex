defmodule App.Condo.Unit do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "condo"
  @types ~w(apartment house commercial parking)
  schema "units" do
    field :number, :string
    field :block, :string
    field :type, :string
    # Fração ideal da unidade no condomínio (0.0–1.0). Soma de todas as unidades = 1.0
    field :fraction, :decimal

    belongs_to :condo, App.Condo.Condo

    has_many :members, App.Condo.Member
    has_many :attendances, App.Assembly.Attendance, foreign_key: :unit_id

    timestamps(type: :utc_datetime)
  end

  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:condo_id, :number, :block, :type, :fraction])
    |> validate_required([:condo_id, :number])
    |> validate_inclusion(:type, @types)
    |> unique_constraint([:condo_id, :block, :number])
    |> foreign_key_constraint(:condo_id)
  end
end

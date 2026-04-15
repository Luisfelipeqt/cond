defmodule App.Condo.CommonArea do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "condo"
  schema "common_areas" do
    field :name, :string
    field :description, :string
    field :capacity, :integer
    field :active, :boolean, default: true
    field :opens_at, :time
    field :closes_at, :time
    field :max_daily_reservations, :integer
    field :min_advance_hours, :integer

    belongs_to :condo, App.Condo.Condo

    has_many :bookings, App.Condo.Booking, foreign_key: :area_id

    timestamps(type: :utc_datetime)
  end

  def changeset(area, attrs) do
    area
    |> cast(attrs, [
      :condo_id,
      :name,
      :description,
      :capacity,
      :active,
      :opens_at,
      :closes_at,
      :max_daily_reservations,
      :min_advance_hours
    ])
    |> validate_required([:condo_id, :name])
    |> foreign_key_constraint(:condo_id)
  end
end

defmodule App.Condo.Booking do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "condo"

  @statuses ~w(pending confirmed cancelled)

  schema "bookings" do
    field :starts_at, :utc_datetime
    field :ends_at, :utc_datetime
    field :status, :string, default: "pending"
    field :notes, :string

    belongs_to :area, App.Condo.CommonArea
    belongs_to :user, App.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:area_id, :user_id, :starts_at, :ends_at, :status, :notes])
    |> validate_required([:area_id, :user_id, :starts_at, :ends_at])
    |> validate_inclusion(:status, @statuses)
    |> validate_time_range()
    |> foreign_key_constraint(:area_id)
    |> foreign_key_constraint(:user_id)
  end

  defp validate_time_range(changeset) do
    starts_at = get_field(changeset, :starts_at)
    ends_at = get_field(changeset, :ends_at)

    if starts_at && ends_at && DateTime.compare(ends_at, starts_at) != :gt do
      add_error(changeset, :ends_at, "must be after starts_at")
    else
      changeset
    end
  end
end

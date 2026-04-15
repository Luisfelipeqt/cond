defmodule App.Assembly.Attendance do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "assembly"

  schema "attendances" do
    field :signed_at, :utc_datetime

    belongs_to :meeting, App.Assembly.Meeting
    belongs_to :unit, App.Condo.Unit
    belongs_to :user, App.Accounts.User
    belongs_to :proxy, App.Assembly.Proxy

    timestamps(type: :utc_datetime)
  end

  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:meeting_id, :unit_id, :user_id, :proxy_id, :signed_at])
    |> validate_required([:meeting_id, :unit_id, :user_id])
    |> unique_constraint([:meeting_id, :unit_id],
      message: "esta unidade já está registrada como presente nesta reunião"
    )
    |> foreign_key_constraint(:meeting_id)
    |> foreign_key_constraint(:unit_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:proxy_id)
  end
end

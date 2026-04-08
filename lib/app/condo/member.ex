defmodule App.Condo.Member do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "condo"
  @roles ~w(owner resident board_member manager)

  schema "condo_members" do
    field :role, :string
    field :active, :boolean, default: true

    belongs_to :user, App.Accounts.User
    belongs_to :condo, App.Condo.Condo
    belongs_to :unit, App.Condo.Unit

    timestamps(type: :utc_datetime)
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:user_id, :condo_id, :unit_id, :role, :active])
    |> validate_required([:user_id, :condo_id, :role])
    |> validate_inclusion(:role, @roles)
    |> unique_constraint([:user_id, :condo_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:condo_id)
    |> foreign_key_constraint(:unit_id)
  end
end

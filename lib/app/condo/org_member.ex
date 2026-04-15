defmodule App.Condo.OrgMember do
  use App.Schema

  @schema_prefix "condo"
  @roles ~w(owner admin staff)

  schema "org_members" do
    field :role, :string, default: "owner"
    field :active, :boolean, default: true

    belongs_to :org, App.Condo.Organization
    belongs_to :user, App.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(org_member, attrs) do
    org_member
    |> cast(attrs, [:org_id, :user_id, :role, :active])
    |> validate_required([:org_id, :user_id, :role])
    |> validate_inclusion(:role, @roles)
    |> unique_constraint([:org_id, :user_id])
    |> foreign_key_constraint(:org_id)
    |> foreign_key_constraint(:user_id)
  end
end

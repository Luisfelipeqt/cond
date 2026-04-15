defmodule App.Assembly.Proxy do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "assembly"

  schema "proxies" do
    field :document_path, :string
    field :validated, :boolean, default: false
    field :validated_at, :utc_datetime

    belongs_to :meeting, App.Assembly.Meeting
    belongs_to :grantor_unit, App.Condo.Unit
    belongs_to :grantor_user, App.Accounts.User
    belongs_to :grantee_user, App.Accounts.User
    belongs_to :validated_by, App.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(proxy, attrs) do
    proxy
    |> cast(attrs, [
      :meeting_id,
      :grantor_unit_id,
      :grantor_user_id,
      :grantee_user_id,
      :document_path
    ])
    |> validate_required([:meeting_id, :grantor_unit_id, :grantor_user_id, :grantee_user_id])
    |> unique_constraint([:meeting_id, :grantor_unit_id],
      message: "esta unidade já possui uma procuração registrada para esta reunião"
    )
    |> foreign_key_constraint(:meeting_id)
    |> foreign_key_constraint(:grantor_unit_id)
    |> foreign_key_constraint(:grantor_user_id)
    |> foreign_key_constraint(:grantee_user_id)
  end

  def validate_changeset(proxy, validated_by_id) do
    proxy
    |> change(validated: true, validated_by_id: validated_by_id, validated_at: DateTime.utc_now())
    |> foreign_key_constraint(:validated_by_id)
  end
end

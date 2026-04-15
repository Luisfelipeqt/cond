defmodule App.Assembly.AgendaItem do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "assembly"

  @item_types ~w(informational deliberative)
  @statuses ~w(pending discussed resolved tabled)

  schema "agenda_items" do
    field :order, :integer
    field :title, :string
    field :description, :string
    field :item_type, :string, default: "deliberative"
    field :status, :string, default: "pending"

    belongs_to :meeting, App.Assembly.Meeting

    has_one :resolution, App.Assembly.Resolution, foreign_key: :agenda_item_id

    timestamps(type: :utc_datetime)
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:meeting_id, :order, :title, :description, :item_type, :status])
    |> validate_required([:meeting_id, :order, :title, :item_type])
    |> validate_inclusion(:item_type, @item_types)
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:order, greater_than: 0)
    |> unique_constraint([:meeting_id, :order],
      message: "já existe um item com esta posição na pauta"
    )
    |> foreign_key_constraint(:meeting_id)
  end
end

defmodule App.Schema do
  @moduledoc """
  Provides a standard schema configuration with UUIDv7 support.

  ## Usage

      defmodule App.MyContext.MySchema do
        use App.Schema

        schema "my_table" do
          field :name, :string
          timestamps(type: :utc_datetime)
        end
      end

  This automatically configures:
  - Primary key as UUIDv7 with autogenerate
  - Foreign key type as UUIDv7
  - Imports Ecto.Schema and Ecto.Changeset
  """

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key {:id, UUIDv7, autogenerate: true}
      @foreign_key_type UUIDv7
    end
  end
end

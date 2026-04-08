defmodule App.Documents.DocumentFile do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "documents"
  @formats ~w(pptx docx pdf)

  schema "document_files" do
    field :format, :string
    field :storage_url, :string
    field :generated_at, :utc_datetime

    belongs_to :document, App.Documents.GeneratedDocument

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(file, attrs) do
    file
    |> cast(attrs, [:document_id, :format, :storage_url, :generated_at])
    |> validate_required([:document_id, :format, :storage_url, :generated_at])
    |> validate_inclusion(:format, @formats)
    |> unique_constraint([:document_id, :format])
    |> foreign_key_constraint(:document_id)
  end
end

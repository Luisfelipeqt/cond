defmodule App.Documents.GeneratedDocument do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "documents"
  @statuses ~w(pending processing completed error)

  schema "generated_documents" do
    field :type, :string
    # JSON filled by the user — or %{"quote_request_id" => id} for quote maps
    field :input_data, :map, default: %{}
    field :status, :string, default: "pending"

    belongs_to :condo, App.Condo.Condo
    belongs_to :template, App.Documents.DocumentTemplate
    belongs_to :user, App.Accounts.User

    has_many :files, App.Documents.DocumentFile, foreign_key: :document_id
    has_many :ai_jobs, App.Documents.AiJob, foreign_key: :document_id

    timestamps(type: :utc_datetime)
  end

  def changeset(doc, attrs) do
    doc
    |> cast(attrs, [:condo_id, :template_id, :user_id, :type, :input_data, :status])
    |> validate_required([:condo_id, :template_id, :user_id, :type])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:condo_id)
    |> foreign_key_constraint(:template_id)
    |> foreign_key_constraint(:user_id)
  end
end

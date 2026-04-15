defmodule App.Documents.AiJob do
  use App.Schema
  import Ecto.Changeset

  @schema_prefix "documents"
  @statuses ~w(pending running completed error)

  schema "ai_jobs" do
    field :llm_model, :string
    field :prompt, :string
    field :llm_response, :string
    field :tokens_used, :integer
    field :status, :string, default: "pending"
    field :executed_at, :utc_datetime

    belongs_to :document, App.Documents.GeneratedDocument

    timestamps(type: :utc_datetime)
  end

  def changeset(job, attrs) do
    job
    |> cast(attrs, [
      :document_id,
      :llm_model,
      :prompt,
      :llm_response,
      :tokens_used,
      :status,
      :executed_at
    ])
    |> validate_required([:document_id, :llm_model, :prompt])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:document_id)
  end
end

defmodule App.Repo.Migrations.AddDocumentAndSummaryToMeetings do
  use Ecto.Migration

  def change do
    alter table(:meetings, prefix: "assembly") do
      add :registered_document_url, :string
      add :summary_pdf_url, :string
      add :summary_content_hash, :string
      add :summary_generated_at, :utc_datetime
    end
  end
end

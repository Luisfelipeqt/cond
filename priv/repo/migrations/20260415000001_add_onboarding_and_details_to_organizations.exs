defmodule App.Repo.Migrations.AddOnboardingAndDetailsToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations, prefix: "condo") do
      # Novos tipos: professional_syndic | property_manager | resident_syndic
      # (renomeia owner_managed → professional_syndic via seeds/reset)

      # Gate de onboarding — nil significa que o onboarding ainda não foi concluído
      add :onboarding_completed_at, :utc_datetime

      # Dados extras da administradora (property_manager)
      add :cnpj, :string
      add :phone, :string
      add :street, :string
      add :street_number, :string
      add :complement, :string
      add :neighborhood, :string
      add :city, :string
      add :state, :string
      add :zip_code, :string
    end
  end
end

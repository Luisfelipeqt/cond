defmodule App.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller.

  Carrega o usuário autenticado e a organização à qual ele pertence.
  A org é usada para:
    - Gate de onboarding (onboarding_completed_at)
    - Limite de membros por tipo
    - Isolamento de dados entre organizações
  """

  alias App.Accounts.User

  defstruct user: nil, org: nil, org_member: nil

  @doc """
  Cria um scope para o usuário dado.
  Carrega a organização e o membro automaticamente.
  """
  def for_user(%User{} = user) do
    {org, org_member} = App.Condo.get_org_and_member_for_user(user.id)
    %__MODULE__{user: user, org: org, org_member: org_member}
  end

  def for_user(nil), do: nil

  @doc "Retorna true se o onboarding da organização foi concluído."
  def onboarding_complete?(%__MODULE__{org: %{onboarding_completed_at: ts}})
      when not is_nil(ts),
      do: true

  def onboarding_complete?(_), do: false

  @doc "Retorna true se o usuário pode gerenciar membros (administradora)."
  def can_manage_members?(%__MODULE__{
        org: %{type: "property_manager"},
        org_member: %{role: role}
      })
      when role in ~w(owner admin),
      do: true

  def can_manage_members?(_), do: false
end

defmodule App.Condo do
  @moduledoc """
  Contexto para gestão de organizações, condomínios e membros.

  Fluxo principal:
    1. Registro: register_org_with_user/1 cria Org + User + OrgMember em transação única
    2. Onboarding: complete_onboarding/1 marca org como pronta para uso
    3. Uso: criação e gestão de condomínios dentro da org
  """

  import Ecto.Query
  alias App.Repo
  use AppWeb, :verified_routes

  alias App.Accounts.{User}
  alias App.Condo.{Condo, Organization, OrgMember, Member}

  # ---------------------------------------------------------------------------
  # Registro
  # ---------------------------------------------------------------------------

  @doc """
  Cria uma Organization + User + OrgMember em uma única transação.

  Attrs esperados:
    - "org_name"  → nome da organização
    - "org_type"  → professional_syndic | property_manager | resident_syndic
    - "email"     → e-mail do usuário dono
  """
  def register_org_with_user(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :org,
      Organization.registration_changeset(%Organization{}, %{
        name: attrs["org_name"],
        type: attrs["org_type"]
      })
    )
    |> Ecto.Multi.insert(:user, fn _ ->
      %User{}
      |> User.changeset(%{email: attrs["email"]})
      |> User.password_changeset(%{
        password: attrs["password"],
        password_confirmation: attrs["password_confirmation"]
      })
    end)
    |> Ecto.Multi.insert(:org_member, fn %{org: org, user: user} ->
      OrgMember.changeset(%OrgMember{}, %{
        org_id: org.id,
        user_id: user.id,
        role: "owner"
      })
    end)
    |> Repo.transaction()
  end

  @doc "Changeset sem struct para validação do formulário de registro."
  def change_registration(attrs \\ %{}) do
    types = %{
      org_name: :string,
      org_type: :string,
      email: :string,
      password: :string,
      password_confirmation: :string
    }

    {%{}, types}
    |> Ecto.Changeset.cast(attrs, Map.keys(types))
    |> Ecto.Changeset.validate_required([:org_name, :org_type, :email, :password],
      message: "obrigatório"
    )
    |> Ecto.Changeset.validate_inclusion(:org_type, Organization.types())
    |> Ecto.Changeset.validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
      message: "formato inválido"
    )
    |> Ecto.Changeset.validate_length(:org_name, min: 2, max: 120)
    |> Ecto.Changeset.validate_length(:password, min: 12, max: 72, message: "mínimo de 12 caracteres")
    |> Ecto.Changeset.validate_confirmation(:password, message: "as senhas não conferem")
  end

  # ---------------------------------------------------------------------------
  # Scope / sessão
  # ---------------------------------------------------------------------------

  @doc """
  Retorna {org, org_member} para o usuário dado.
  Chamado pelo App.Accounts.Scope ao montar a sessão.
  """
  def get_org_and_member_for_user(user_id) do
    org_member =
      OrgMember
      |> where([m], m.user_id == ^user_id and m.active == true)
      |> preload(:org)
      |> Repo.one()

    case org_member do
      nil -> {nil, nil}
      %OrgMember{org: org} = member -> {org, member}
    end
  end

  # ---------------------------------------------------------------------------
  # Onboarding
  # ---------------------------------------------------------------------------

  @doc "Conclui o onboarding da organização."
  def complete_onboarding(%Organization{} = org) do
    org
    |> Organization.complete_onboarding_changeset()
    |> Repo.update()
  end

  @doc "Salva dados complementares da administradora durante onboarding."
  def update_org_details(%Organization{} = org, attrs) do
    org
    |> Organization.property_manager_changeset(attrs)
    |> Repo.update()
  end

  @doc "Changeset para o formulário de dados da administradora."
  def change_org_details(%Organization{} = org, attrs \\ %{}) do
    Organization.property_manager_changeset(org, attrs)
  end

  # ---------------------------------------------------------------------------
  # Membros da organização
  # ---------------------------------------------------------------------------

  @doc "Lista membros ativos da organização com o usuário pré-carregado."
  def list_org_members(%Organization{id: org_id}) do
    OrgMember
    |> where([m], m.org_id == ^org_id and m.active == true)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Convida um novo membro para a organização (apenas property_manager).

  Fluxo:
    1. Cria o usuário se não existir
    2. Cria ou reativa o OrgMember
    3. Envia magic link de acesso

  Retorna {:ok, user} ou {:error, changeset | :not_allowed}.
  """
  def invite_org_member(org, email, role \\ "staff")

  def invite_org_member(%Organization{type: "property_manager"} = org, email, role) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:user, fn _repo, _ ->
      case App.Accounts.get_user_by_email(email) do
        nil ->
          random_password = Base.encode64(:crypto.strong_rand_bytes(32))

          %User{}
          |> User.changeset(%{email: email})
          |> User.password_changeset(%{password: random_password, password_confirmation: random_password})
          |> Repo.insert()

        user ->
          {:ok, user}
      end
    end)
    |> Ecto.Multi.run(:member, fn _repo, %{user: user} ->
      case Repo.get_by(OrgMember, org_id: org.id, user_id: user.id) do
        nil ->
          OrgMember.changeset(%OrgMember{}, %{
            org_id: org.id,
            user_id: user.id,
            role: role,
            active: true
          })
          |> Repo.insert()

        %OrgMember{active: false} = existing ->
          existing |> Ecto.Changeset.change(active: true) |> Repo.update()

        existing ->
          {:ok, existing}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} ->
        App.Accounts.deliver_login_instructions(user, &url(~p"/users/log-in/#{&1}"))
        {:ok, user}

      {:error, _step, changeset, _} ->
        {:error, changeset}
    end
  end

  def invite_org_member(%Organization{}, _email, _role) do
    {:error, :not_allowed}
  end

  @doc "Desativa um membro da organização (não pode remover o owner)."
  def deactivate_org_member(%OrgMember{role: "owner"}) do
    {:error, :cannot_remove_owner}
  end

  def deactivate_org_member(%OrgMember{} = member) do
    member |> Ecto.Changeset.change(active: false) |> Repo.update()
  end

  # ---------------------------------------------------------------------------
  # Condomínios
  # ---------------------------------------------------------------------------

  @doc "Lista todos os condomínios da organização."
  def list_condos_for_org(%Organization{id: org_id}) do
    Condo
    |> where([c], c.org_id == ^org_id)
    |> preload(:org)
    |> Repo.all()
  end

  @doc "Lista todos os condomínios dos quais o usuário é membro ativo."
  def list_condos_for_user(user_id) do
    Condo
    |> join(:inner, [c], m in Member,
      on: m.condo_id == c.id and m.user_id == ^user_id and m.active == true
    )
    |> preload(:org)
    |> Repo.all()
  end

  @doc "Busca um condomínio pelo id, levantando exceção se não encontrado."
  def get_condo!(id) do
    Condo
    |> Repo.get!(id)
    |> Repo.preload(:org)
  end

  @doc """
  Cria um Condo + Member (board_member) dentro de uma organização.
  Valida o limite de condomínios para resident_syndic (máx. 1).
  """
  def create_condo(attrs, %Organization{} = org, user_id) do
    with :ok <- check_condo_limit(org) do
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:condo, fn _ ->
        %Condo{}
        |> Condo.changeset(Map.put(attrs, "org_id", org.id))
      end)
      |> Ecto.Multi.insert(:member, fn %{condo: condo} ->
        Member.changeset(%Member{}, %{
          user_id: user_id,
          condo_id: condo.id,
          role: "board_member"
        })
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{condo: condo}} -> {:ok, condo}
        {:error, _step, changeset, _} -> {:error, changeset}
      end
    end
  end

  @doc "Lista todas as unidades de um condomínio, ordenadas por bloco e número."
  def list_units_for_condo(condo_id) do
    App.Condo.Unit
    |> where([u], u.condo_id == ^condo_id)
    |> order_by([u], [u.block, u.number])
    |> Repo.all()
  end

  @doc "Busca uma unidade pelo id, levantando exceção se não encontrada."
  def get_unit!(id), do: Repo.get!(App.Condo.Unit, id)

  @doc "Cria uma unidade em um condomínio."
  def create_unit(attrs) do
    %App.Condo.Unit{}
    |> App.Condo.Unit.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Atualiza uma unidade."
  def update_unit(%App.Condo.Unit{} = unit, attrs) do
    unit
    |> App.Condo.Unit.changeset(attrs)
    |> Repo.update()
  end

  @doc "Remove uma unidade."
  def delete_unit(%App.Condo.Unit{} = unit), do: Repo.delete(unit)

  @doc "Retorna um changeset para forms de unidade."
  def change_unit(attrs \\ %{}), do: App.Condo.Unit.changeset(%App.Condo.Unit{}, attrs)
  def change_unit(%App.Condo.Unit{} = unit, attrs), do: App.Condo.Unit.changeset(unit, attrs)

  @doc "Retorna um changeset para forms de criação/edição de condomínio."
  def change_condo(attrs \\ %{}) do
    Condo.changeset(attrs)
  end

  def change_condo(%Condo{} = condo, attrs) do
    Condo.changeset(condo, attrs)
  end

  defp check_condo_limit(%Organization{type: "resident_syndic", id: org_id}) do
    count = Repo.aggregate(from(c in Condo, where: c.org_id == ^org_id), :count)
    if count >= 1, do: {:error, :condo_limit_reached}, else: :ok
  end

  defp check_condo_limit(_org), do: :ok
end

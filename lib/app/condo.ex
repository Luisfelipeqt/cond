defmodule App.Condo do
  @moduledoc """
  Contexto para gestão de condomínios e organizações.

  Fluxo principal:
    1. Usuário cria uma Organization (administradora ou síndico)
    2. Dentro da org, cria um ou mais Condomínio (Condo)
    3. O usuário criador vira board_member do condomínio
  """

  import Ecto.Query
  alias App.Repo
  alias App.Condo.{Condo, Organization, Member}

  # ---------------------------------------------------------------------------
  # Condomínios
  # ---------------------------------------------------------------------------

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
  Cria uma Organization + Condo + Member (board_member) em uma única transação.

  Espera attrs com:
    - "org_name"     → nome da organização
    - "org_type"     → owner_managed | property_manager
    - "name"         → nome do condomínio
    - "cnpj"         → CNPJ (opcional)
    - "total_units"  → nº de unidades (opcional)
    - endereço: street, street_number, city, state, zip_code
  """
  def create_condo(attrs, user_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:org, Organization.changeset(%Organization{}, %{
      name: attrs["org_name"] || attrs[:org_name] || attrs["name"],
      type: attrs["org_type"] || attrs[:org_type] || "owner_managed"
    }))
    |> Ecto.Multi.insert(:condo, fn %{org: org} ->
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
      {:error, _step, changeset, _changes} -> {:error, changeset}
    end
  end

  @doc "Retorna um changeset para forms de criação/edição de condomínio."
  def change_condo(%Condo{} = condo \\ %Condo{}, attrs \\ %{}) do
    Condo.changeset(condo, attrs)
  end
end

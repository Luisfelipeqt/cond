defmodule App.AccountsFixtures do
  @moduledoc """
  Helpers para criar entidades de teste via `App.Accounts` e `App.Condo`.

  Todo usuário DEVE ter uma organização — use `valid_registration_attrs/1`
  como base para qualquer fixture que crie usuários.
  """

  import Ecto.Query

  alias App.Accounts
  alias App.Accounts.Scope

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  @doc "Atributos completos para registrar org + usuário via Condo.register_org_with_user/1."
  def valid_registration_attrs(attrs \\ %{}) do
    string_attrs =
      Map.new(attrs, fn
        {k, v} when is_atom(k) -> {Atom.to_string(k), v}
        {k, v} -> {k, v}
      end)

    Enum.into(string_attrs, %{
      "org_name" => "Org #{System.unique_integer()}",
      "org_type" => "professional_syndic",
      "email" => unique_user_email(),
      "password" => valid_user_password(),
      "password_confirmation" => valid_user_password()
    })
  end

  @doc "Cria um usuário com org, sem confirmed_at."
  def unconfirmed_user_fixture(attrs \\ %{}) do
    {:ok, %{user: user}} =
      attrs
      |> valid_registration_attrs()
      |> App.Condo.register_org_with_user()

    user
  end

  @doc "Cria um usuário com org e confirmed_at definido."
  def user_fixture(attrs \\ %{}) do
    user = unconfirmed_user_fixture(attrs)
    {:ok, user} = App.Repo.update(Accounts.User.confirm_changeset(user))
    user
  end

  def user_scope_fixture do
    user = user_fixture()
    user_scope_fixture(user)
  end

  def user_scope_fixture(user) do
    Scope.for_user(user)
  end

  def set_password(user) do
    {:ok, {user, _expired_tokens}} =
      Accounts.update_user_password(user, %{password: valid_user_password()})

    user
  end

  @doc """
  Captura o token de email enviado via Oban+Swoosh.

  Passa uma URL-builder `&\"[TOKEN]\#{&1}[TOKEN]\"` para a função,
  depois lê a mensagem `{:email, email}` deixada pelo Swoosh.Adapters.Test.
  Requer `config :app, Oban, testing: :inline` em test.exs.
  """
  def extract_user_token(fun) do
    {:ok, _} = fun.(&"[TOKEN]#{&1}[TOKEN]")

    receive do
      {:email, %Swoosh.Email{text_body: text_body}} ->
        [_, token | _] = String.split(text_body, "[TOKEN]")
        token
    after
      2000 -> raise "nenhum email recebido em 2s — Oban.testing: :inline configurado?"
    end
  end

  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    App.Repo.update_all(
      from(t in Accounts.UserToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at]
    )
  end

  def generate_user_magic_link_token(user) do
    {encoded_token, user_token} = Accounts.UserToken.build_email_token(user, "login")
    App.Repo.insert!(user_token)
    {encoded_token, user_token.token}
  end

  def generate_user_confirm_token(user) do
    {encoded_token, user_token} = Accounts.UserToken.build_email_token(user, "confirm")
    App.Repo.insert!(user_token)
    {encoded_token, user_token.token}
  end

  def offset_user_token(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)

    App.Repo.update_all(
      from(ut in Accounts.UserToken, where: ut.token == ^token),
      set: [inserted_at: dt, authenticated_at: dt]
    )
  end
end

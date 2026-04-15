# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias App.Accounts

# ---------------------------------------------------------------------------
# Usuário de desenvolvimento
# ---------------------------------------------------------------------------

email = "dev@sindico.app"
password = "Dev123456!"

case Accounts.get_user_by_email(email) do
  nil ->
    {:ok, user} = Accounts.register_user(%{email: email, password: password})

    # Confirma o e-mail direto no banco para não precisar do fluxo de e-mail
    App.Repo.update!(
      Ecto.Changeset.change(user, confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second))
    )

    IO.puts("✓ Usuário criado: #{email} / #{password}")

  _existing ->
    IO.puts("→ Usuário já existe: #{email}")
end

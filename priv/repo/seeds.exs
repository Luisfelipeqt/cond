# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias App.{Repo, Condo, Accounts}
alias App.Condo.{Organization, OrgMember}

email = "dev@sindico.app"
password = "Dev@sindico2025"

user =
  case Accounts.get_user_by_email(email) do
    nil ->
      {:ok, %{user: user}} =
        Condo.register_org_with_user(%{
          "org_name" => "Síndico App Dev",
          "org_type" => "professional_syndic",
          "email" => email,
          "password" => password,
          "password_confirmation" => password
        })

      Repo.update!(Accounts.User.confirm_changeset(user))
      IO.puts("✓ Org + usuário criados: #{email} / #{password}")
      user

    existing ->
      if is_nil(existing.hashed_password) || !String.starts_with?(existing.hashed_password, "$argon2") do
        Repo.update!(Ecto.Changeset.change(existing, hashed_password: Argon2.hash_pwd_salt(password)))
        IO.puts("→ Senha definida para usuário existente: #{email}")
      else
        IO.puts("→ Usuário já existe: #{email}")
      end

      existing
  end

# Garante que o usuário tem org e org_member
{org, _member} = Condo.get_org_and_member_for_user(user.id)

if is_nil(org) do
  {:ok, org} =
    Repo.insert(
      Organization.registration_changeset(%Organization{}, %{
        name: "Síndico App Dev",
        type: "professional_syndic"
      })
    )

  {:ok, _} =
    Repo.insert(
      OrgMember.changeset(%OrgMember{}, %{
        org_id: org.id,
        user_id: user.id,
        role: "owner",
        active: true
      })
    )

  IO.puts("✓ Org + org_member criados para #{email}")
end

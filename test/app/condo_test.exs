defmodule App.CondoTest do
  use App.DataCase

  alias App.Condo
  alias App.Accounts
  alias App.Accounts.User
  alias App.Condo.{Organization, OrgMember}

  import App.AccountsFixtures

  # ---------------------------------------------------------------------------
  # register_org_with_user/1
  # ---------------------------------------------------------------------------

  describe "register_org_with_user/1" do
    test "cria org, usuário e org_member owner em uma única transação" do
      attrs = valid_registration_attrs()

      assert {:ok, %{org: org, user: user, org_member: member}} =
               Condo.register_org_with_user(attrs)

      assert org.name == attrs["org_name"]
      assert org.type == attrs["org_type"]
      assert user.email == attrs["email"]
      assert member.role == "owner"
      assert member.user_id == user.id
      assert member.org_id == org.id
    end

    test "a senha é hashada com argon2 — nunca salva em texto claro" do
      attrs = valid_registration_attrs()
      {:ok, %{user: user}} = Condo.register_org_with_user(attrs)

      assert user.hashed_password != nil
      assert user.hashed_password != attrs["password"]
      assert user.password == nil
    end

    test "o hash argon2 é verificável com a senha original" do
      attrs = valid_registration_attrs()
      {:ok, %{user: user}} = Condo.register_org_with_user(attrs)

      assert User.valid_password?(user, attrs["password"])
    end

    test "usuário começa sem confirmed_at" do
      attrs = valid_registration_attrs()
      {:ok, %{user: user}} = Condo.register_org_with_user(attrs)

      assert is_nil(user.confirmed_at)
    end

    test "usuário registrado consegue logar com email e senha corretos" do
      attrs = valid_registration_attrs()
      {:ok, %{user: user}} = Condo.register_org_with_user(attrs)

      found = Accounts.get_user_by_email_and_password(attrs["email"], attrs["password"])
      assert found.id == user.id
    end

    test "usuário registrado não loga com senha errada" do
      attrs = valid_registration_attrs()
      {:ok, _} = Condo.register_org_with_user(attrs)

      refute Accounts.get_user_by_email_and_password(attrs["email"], "senha_errada_aqui")
    end

    test "email duplicado retorna erro e reverte a transação" do
      attrs = valid_registration_attrs()
      {:ok, _} = Condo.register_org_with_user(attrs)

      org_count_before = Repo.aggregate(Organization, :count)

      assert {:error, :user, changeset, _} = Condo.register_org_with_user(attrs)
      assert "has already been taken" in errors_on(changeset).email

      assert Repo.aggregate(Organization, :count) == org_count_before
    end

    test "org_name ausente retorna erro e não cria usuário" do
      attrs = Map.delete(valid_registration_attrs(), "org_name")

      user_count_before = Repo.aggregate(User, :count)

      assert {:error, :org, changeset, _} = Condo.register_org_with_user(attrs)
      assert %{name: _} = errors_on(changeset)
      assert Repo.aggregate(User, :count) == user_count_before
    end

    test "email ausente retorna erro e não cria org" do
      attrs = Map.delete(valid_registration_attrs(), "email")

      org_count_before = Repo.aggregate(Organization, :count)

      assert {:error, :user, changeset, _} = Condo.register_org_with_user(attrs)
      assert %{email: _} = errors_on(changeset)
      assert Repo.aggregate(Organization, :count) == org_count_before
    end

    test "email com formato inválido retorna erro" do
      attrs = valid_registration_attrs(%{"email" => "nao-e-um-email"})
      assert {:error, :user, changeset, _} = Condo.register_org_with_user(attrs)
      assert "must have the @ sign and no spaces" in errors_on(changeset).email
    end

    test "email muito longo (> 160 chars) retorna erro" do
      longo = String.duplicate("a", 156) <> "@b.co"
      attrs = valid_registration_attrs(%{"email" => longo})
      assert {:error, :user, changeset, _} = Condo.register_org_with_user(attrs)
      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "senha com menos de 12 caracteres retorna erro" do
      attrs = valid_registration_attrs(%{"password" => "curta", "password_confirmation" => "curta"})
      assert {:error, :user, changeset, _} = Condo.register_org_with_user(attrs)
      assert "should be at least 12 character(s)" in errors_on(changeset).password
    end

    test "senha com mais de 72 caracteres retorna erro" do
      longa = String.duplicate("a", 73)
      attrs = valid_registration_attrs(%{"password" => longa, "password_confirmation" => longa})
      assert {:error, :user, changeset, _} = Condo.register_org_with_user(attrs)
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "org_type inválido retorna erro" do
      attrs = valid_registration_attrs(%{"org_type" => "tipo_inexistente"})
      assert {:error, :org, changeset, _} = Condo.register_org_with_user(attrs)
      assert %{type: _} = errors_on(changeset)
    end

    test "org_name pode se repetir entre organizações diferentes" do
      assert {:ok, _} =
               Condo.register_org_with_user(valid_registration_attrs(%{"org_name" => "Nome Igual"}))

      assert {:ok, _} =
               Condo.register_org_with_user(valid_registration_attrs(%{"org_name" => "Nome Igual"}))
    end

    test "suporta todos os tipos de organização válidos" do
      for type <- Organization.types() do
        attrs = valid_registration_attrs(%{"org_type" => type})
        assert {:ok, %{org: org}} = Condo.register_org_with_user(attrs)
        assert org.type == type
      end
    end

    test "org_member criado é ativo por padrão" do
      {:ok, %{org_member: member}} = Condo.register_org_with_user(valid_registration_attrs())
      assert member.active == true
    end
  end

  # ---------------------------------------------------------------------------
  # invite_org_member/3
  # ---------------------------------------------------------------------------

  describe "invite_org_member/3" do
    setup do
      {:ok, %{org: pm_org}} =
        Condo.register_org_with_user(
          valid_registration_attrs(%{"org_type" => "property_manager"})
        )

      {:ok, %{org: resident_org}} =
        Condo.register_org_with_user(
          valid_registration_attrs(%{"org_type" => "resident_syndic"})
        )

      %{pm_org: pm_org, resident_org: resident_org}
    end

    test "apenas property_manager pode convidar membros", %{resident_org: org} do
      assert {:error, :not_allowed} = Condo.invite_org_member(org, "convidado@example.com")
    end

    test "professional_syndic não pode convidar membros", %{} do
      {:ok, %{org: org}} =
        Condo.register_org_with_user(
          valid_registration_attrs(%{"org_type" => "professional_syndic"})
        )

      assert {:error, :not_allowed} = Condo.invite_org_member(org, "convidado@example.com")
    end

    test "property_manager convida novo usuário com hash aleatório (acesso por magic link)", %{
      pm_org: org
    } do
      assert {:ok, user} = Condo.invite_org_member(org, "staff@example.com")
      assert user.email == "staff@example.com"
      # hash existe mas ninguém conhece a senha — único acesso é via magic link
      assert user.hashed_password != nil
      refute App.Accounts.User.valid_password?(user, "qualquer_senha_aqui")
    end

    test "usuário convidado vira membro ativo da org", %{pm_org: org} do
      {:ok, user} = Condo.invite_org_member(org, "staff@example.com")

      member = Repo.get_by(OrgMember, org_id: org.id, user_id: user.id)
      assert member.active == true
      assert member.role == "staff"
    end

    test "convidar email já existente reutiliza o usuário existente", %{} do
      existing = unconfirmed_user_fixture()

      {:ok, %{org: org2}} =
        Condo.register_org_with_user(
          valid_registration_attrs(%{"org_type" => "property_manager"})
        )

      assert {:ok, user} = Condo.invite_org_member(org2, existing.email)
      assert user.id == existing.id
    end

    test "reativar membro desativado", %{pm_org: org} do
      {:ok, user} = Condo.invite_org_member(org, "reativado@example.com")
      member = Repo.get_by(OrgMember, org_id: org.id, user_id: user.id)

      Condo.deactivate_org_member(member)
      assert Repo.get!(OrgMember, member.id).active == false

      {:ok, _} = Condo.invite_org_member(org, "reativado@example.com")
      assert Repo.get!(OrgMember, member.id).active == true
    end
  end

  # ---------------------------------------------------------------------------
  # deactivate_org_member/1
  # ---------------------------------------------------------------------------

  describe "deactivate_org_member/1" do
    test "não permite remover o owner" do
      {:ok, %{org_member: owner}} = Condo.register_org_with_user(valid_registration_attrs())
      assert {:error, :cannot_remove_owner} = Condo.deactivate_org_member(owner)
    end

    test "desativa membro staff" do
      {:ok, %{org: org}} =
        Condo.register_org_with_user(
          valid_registration_attrs(%{"org_type" => "property_manager"})
        )

      {:ok, user} = Condo.invite_org_member(org, "staff@example.com")
      member = Repo.get_by(OrgMember, org_id: org.id, user_id: user.id)

      assert {:ok, updated} = Condo.deactivate_org_member(member)
      assert updated.active == false
    end
  end
end

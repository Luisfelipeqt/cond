defmodule AppWeb.UserLive.RegistrationTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import App.AccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Criar"
      assert html =~ "Entrar"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, ~p"/condominios")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(registration: %{"email" => "with spaces"})

      assert result =~ "formato inválido"
    end
  end

  describe "register user" do
    test "creates account, envia email de confirmação e não loga", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      email = unique_user_email()

      form =
        form(lv, "#registration_form",
          registration: %{
            "org_type" => "professional_syndic",
            "org_name" => "Org Teste",
            "email" => email,
            "password" => valid_user_password(),
            "password_confirmation" => valid_user_password()
          }
        )

      {:ok, _lv, html} =
        render_submit(form)
        |> follow_redirect(conn, ~p"/users/log-in")

      assert html =~ "Enviamos um link de confirmação"
    end

    test "renders flash error for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture()

      html =
        lv
        |> form("#registration_form",
          registration: %{
            "org_type" => "professional_syndic",
            "org_name" => "Org Teste",
            "email" => user.email,
            "password" => valid_user_password(),
            "password_confirmation" => valid_user_password()
          }
        )
        |> render_submit()

      assert html =~ "Erro ao criar" or html =~ "Verifique os dados"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Entrar link is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element("a[href='/users/log-in']")
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log-in")

      assert login_html =~ "Entrar"
    end
  end
end

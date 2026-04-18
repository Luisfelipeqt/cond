defmodule AppWeb.UserLive.EmailConfirmation do
  use AppWeb, :live_view

  alias App.Accounts

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    logged_in? = socket.assigns.current_scope && socket.assigns.current_scope.user

    case Accounts.confirm_user(token) do
      {:ok, _user} ->
        destination = if logged_in?, do: ~p"/onboarding", else: ~p"/users/log-in"

        {:ok,
         socket
         |> put_flash(:info, "E-mail confirmado! #{if logged_in?, do: "Continue o cadastro da sua conta.", else: "Faça login para continuar."}")
         |> push_navigate(to: destination)}

      {:error, :invalid_token} ->
        {:ok,
         socket
         |> put_flash(:error, "Link de confirmação inválido ou expirado.")
         |> push_navigate(to: ~p"/users/log-in")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div></div>
    """
  end
end

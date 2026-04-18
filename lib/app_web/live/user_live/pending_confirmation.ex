defmodule AppWeb.UserLive.PendingConfirmation do
  use AppWeb, :live_view

  alias App.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope && socket.assigns.current_scope.user

    cond do
      is_nil(user) ->
        {:ok, push_navigate(socket, to: ~p"/users/log-in")}

      user.confirmed_at ->
        {:ok, push_navigate(socket, to: ~p"/onboarding")}

      true ->
        {:ok,
         socket
         |> assign(:page_title, "Confirme seu e-mail")
         |> assign(:user, user)
         |> assign(:resent, false)}
    end
  end

  @impl true
  def handle_event("reenviar", _params, socket) do
    user = socket.assigns.user

    Accounts.deliver_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))

    {:noreply, assign(socket, :resent, true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <div class="min-h-screen bg-base-200 flex flex-col items-center justify-center p-4">
      <div class="mb-8 text-center">
        <.link href={~p"/"} class="text-xl font-bold text-base-content tracking-tight">
          síndico.app
        </.link>
      </div>

      <div class="card bg-base-100 border border-base-300 w-full max-w-md shadow-sm">
        <div class="card-body gap-5 p-8 text-center">
          <div class="flex justify-center">
            <div class="w-14 h-14 rounded-full bg-primary/10 flex items-center justify-center">
              <.icon name="hero-envelope" class="w-7 h-7 text-primary" />
            </div>
          </div>

          <div class="space-y-1">
            <h1 class="text-xl font-bold text-base-content">Confirme seu e-mail</h1>
            <p class="text-sm text-base-content/60">
              Enviamos um link de confirmação para
            </p>
            <p class="text-sm font-semibold text-base-content">{@user.email}</p>
          </div>

          <p class="text-sm text-base-content/60">
            Clique no link do e-mail para ativar sua conta e continuar o cadastro.
            Verifique também a caixa de spam.
          </p>

          <div :if={@resent} class="alert alert-success text-sm py-2">
            <.icon name="hero-check-circle" class="size-4 shrink-0" />
            <span>Novo e-mail enviado! Verifique sua caixa de entrada.</span>
          </div>

          <.button
            :if={!@resent}
            phx-click="reenviar"
            phx-disable-with="Enviando..."
            class="btn btn-outline w-full"
          >
            Reenviar e-mail de confirmação
          </.button>

          <.link
            navigate={~p"/users/log-out"}
            method="delete"
            class="text-xs text-base-content/40 hover:text-base-content transition-colors"
          >
            Usar outro e-mail? Sair da conta
          </.link>
        </div>
      </div>

      <div class="mt-6">
        <Layouts.theme_toggle />
      </div>
    </div>
    """
  end
end

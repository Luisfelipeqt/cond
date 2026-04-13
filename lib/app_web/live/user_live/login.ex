defmodule AppWeb.UserLive.Login do
  use AppWeb, :live_view

  alias App.Accounts

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

      <div class="card bg-base-100 border border-base-300 w-full max-w-sm shadow-sm">
        <div class="card-body gap-5 p-8">
          <div class="text-center space-y-1">
            <h1 class="text-xl font-bold text-base-content">Entrar na sua conta</h1>
            <p class="text-sm text-base-content/60">
              <%= if @current_scope do %>
                Confirme sua identidade para continuar.
              <% else %>
                Não tem conta?
                <.link navigate={~p"/users/register"} class="text-primary font-medium hover:underline">
                  Cadastre-se
                </.link>
              <% end %>
            </p>
          </div>

          <div :if={local_mail_adapter?()} class="alert alert-info text-sm py-2">
            <.icon name="hero-information-circle" class="size-4 shrink-0" />
            <span>
              Veja os emails em <.link href="/dev/mailbox" class="underline">mailbox</.link>.
            </span>
          </div>

          <.form
            :let={f}
            for={@form}
            id="login_form_magic"
            action={~p"/users/log-in"}
            phx-submit="submit_magic"
          >
            <.input
              readonly={!!@current_scope}
              field={f[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              spellcheck="false"
              required
              phx-mounted={JS.focus()}
            />
            <.button class="btn btn-primary w-full mt-1">
              Entrar com link no email <span aria-hidden="true">→</span>
            </.button>
          </.form>

          <div class="divider text-xs text-base-content/40">ou com senha</div>

          <.form
            :let={f}
            for={@form}
            id="login_form_password"
            action={~p"/users/log-in"}
            phx-submit="submit_password"
            phx-trigger-action={@trigger_submit}
          >
            <.input
              readonly={!!@current_scope}
              field={f[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              spellcheck="false"
              required
            />
            <.input
              field={@form[:password]}
              type="password"
              label="Senha"
              autocomplete="current-password"
              spellcheck="false"
            />
            <.button class="btn btn-primary w-full mt-1" name={@form[:remember_me].name} value="true">
              Entrar e manter conectado <span aria-hidden="true">→</span>
            </.button>
            <.button class="btn btn-outline w-full mt-2">
              Entrar apenas desta vez
            </.button>
          </.form>
        </div>
      </div>

      <div class="mt-6">
        <Layouts.theme_toggle />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:app, App.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end

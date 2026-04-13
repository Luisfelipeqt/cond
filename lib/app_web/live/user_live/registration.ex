defmodule AppWeb.UserLive.Registration do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.Accounts.User

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
            <h1 class="text-xl font-bold text-base-content">Criar sua conta</h1>
            <p class="text-sm text-base-content/60">
              Já tem conta?
              <.link navigate={~p"/users/log-in"} class="text-primary font-medium hover:underline">
                Entrar
              </.link>
            </p>
          </div>

          <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
            <.input
              field={@form[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              spellcheck="false"
              required
              phx-mounted={JS.focus()}
            />
            <.button phx-disable-with="Criando conta..." class="btn btn-primary w-full mt-1">
              Criar conta
            </.button>
          </.form>

          <p class="text-xs text-center text-base-content/40">
            Ao criar uma conta, você concorda com os nossos <a
              href="#"
              class="underline hover:text-base-content transition-colors"
            >termos de uso</a>.
          </p>
        </div>
      </div>

      <div class="mt-6">
        <Layouts.theme_toggle />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: AppWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_email(%User{}, %{}, validate_unique: false)

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/users/log-in/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "An email was sent to #{user.email}, please access it to confirm your account."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_email(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end

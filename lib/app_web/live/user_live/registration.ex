defmodule AppWeb.UserLive.Registration do
  use AppWeb, :live_view

  alias App.Condo
  alias App.Accounts

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: AppWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Condo.change_registration()

    socket
    |> assign(:page_title, "Criar conta")
    |> assign_form(changeset)
    |> ok()
  end

  @impl true
  def handle_event("validate", %{"registration" => params}, socket) do
    changeset =
      params
      |> Condo.change_registration()
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"registration" => params}, socket) do
    case Condo.register_org_with_user(params) do
      {:ok, %{user: user}} ->
        {:ok, _} =
          Accounts.deliver_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        socket
        |> put_flash(
          :info,
          "Conta criada! Enviamos um link de confirmação para #{user.email}."
        )
        |> push_navigate(to: ~p"/users/log-in")
        |> noreply()

      {:error, :org, changeset, _} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, :user, _changeset, _} ->
        socket
        |> put_flash(:error, "Erro ao criar usuário. Verifique os dados e tente novamente.")
        |> noreply()

      {:error, _step, _changeset, _} ->
        socket
        |> put_flash(:error, "Ocorreu um erro. Tente novamente.")
        |> noreply()
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "registration"))
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
        <div class="card-body gap-6 p-8">
          <div class="text-center space-y-1">
            <h1 class="text-xl font-bold text-base-content">Criar sua conta</h1>
            <p class="text-sm text-base-content/60">
              Já tem conta?
              <.link navigate={~p"/users/log-in"} class="text-primary font-medium hover:underline">
                Entrar
              </.link>
            </p>
          </div>

          <.form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            class="space-y-4"
            novalidate
          >
            <%!-- Tipo de perfil --%>
            <div class="form-control gap-1.5">
              <label class="label py-0">
                <span class="label-text font-medium text-sm">Qual melhor descreve você?</span>
              </label>
              <div class="grid grid-cols-1 gap-2">
                <label
                  :for={
                    {value, label, desc} <- [
                      {"professional_syndic", "Síndico profissional",
                       "Gerencio vários condomínios por conta própria"},
                      {"property_manager", "Administradora",
                       "Sou uma empresa de gestão de condomínios"},
                      {"resident_syndic", "Síndico morador",
                       "Fui eleito síndico do meu próprio prédio"}
                    ]
                  }
                  class={[
                    "flex items-start gap-3 border rounded-xl p-3.5 cursor-pointer transition-all",
                    if(Phoenix.HTML.Form.input_value(@form, :org_type) == value,
                      do: "border-primary bg-primary/5",
                      else: "border-base-300 hover:border-base-400"
                    )
                  ]}
                >
                  <input
                    type="radio"
                    name={@form[:org_type].name}
                    value={value}
                    checked={Phoenix.HTML.Form.input_value(@form, :org_type) == value}
                    class="radio radio-primary radio-sm mt-0.5 flex-shrink-0"
                  />
                  <div>
                    <p class="text-sm font-semibold text-base-content">{label}</p>
                    <p class="text-xs text-base-content/50">{desc}</p>
                  </div>
                </label>
              </div>
              <p
                :for={msg <- Enum.map(@form[:org_type].errors, &translate_error(&1))}
                class="text-error text-xs mt-1"
              >
                {msg}
              </p>
            </div>

            <%!-- Nome da organização --%>
            <.input
              field={@form[:org_name]}
              type="text"
              label="Nome da organização / seu nome"
              placeholder="Ex: Gestão Silva ou Administradora Central"
              required
              phx-debounce="blur"
            />

            <%!-- E-mail --%>
            <.input
              field={@form[:email]}
              type="email"
              label="E-mail de acesso"
              placeholder="voce@email.com"
              required
              autocomplete="username"
              spellcheck="false"
              phx-mounted={JS.focus()}
              phx-debounce="blur"
            />

            <%!-- Senha --%>
            <.input
              field={@form[:password]}
              type="password"
              label="Senha"
              placeholder="Mínimo 12 caracteres"
              required
              autocomplete="new-password"
              phx-debounce="blur"
            />

            <%!-- Confirmação de senha --%>
            <.input
              field={@form[:password_confirmation]}
              type="password"
              label="Confirmar senha"
              placeholder="Repita a senha"
              required
              autocomplete="new-password"
              phx-debounce="blur"
            />

            <.button
              type="submit"
              phx-disable-with="Criando conta..."
              class="btn btn-primary w-full min-h-[48px] text-base mt-2"
            >
              Criar conta e receber acesso
            </.button>
          </.form>

          <p class="text-xs text-center text-base-content/40">
            Ao criar uma conta, você concorda com os nossos <.link
              navigate={~p"/termos"}
              class="underline hover:text-base-content transition-colors"
            >
              termos de uso
            </.link>.
          </p>
        </div>
      </div>

      <div class="mt-6">
        <Layouts.theme_toggle />
      </div>
    </div>
    """
  end
end

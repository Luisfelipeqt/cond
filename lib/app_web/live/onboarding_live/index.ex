defmodule AppWeb.OnboardingLive.Index do
  use AppWeb, :live_view

  alias App.Condo

  @impl true
  def mount(_params, _session, socket) do
    org = socket.assigns.current_scope.org

    # Se o onboarding já foi concluído, redireciona direto
    if org && org.onboarding_completed_at do
      {:ok, redirect(socket, to: ~p"/condominios")}
    else
      # Administradora começa no passo de dados da org; demais vão direto para o condomínio
      initial_step =
        if org && org.type == "property_manager", do: :org_details, else: :first_condo

      socket
      |> assign(:page_title, "Configure sua conta")
      |> assign(:step, initial_step)
      |> assign(:org, org)
      |> assign_org_details_form(org)
      |> assign_condo_form()
      |> ok()
    end
  end

  # ---------------------------------------------------------------------------
  # Passo 1 — Dados da administradora (apenas property_manager)
  # ---------------------------------------------------------------------------

  @impl true
  def handle_event("validate_org_details", %{"org" => params}, socket) do
    form =
      socket.assigns.org
      |> Condo.change_org_details(params)
      |> Map.put(:action, :validate)
      |> to_form(as: "org")

    {:noreply, assign(socket, :org_details_form, form)}
  end

  def handle_event("save_org_details", %{"org" => params}, socket) do
    case Condo.update_org_details(socket.assigns.org, params) do
      {:ok, org} ->
        socket
        |> assign(:org, org)
        |> assign(:step, :first_condo)
        |> noreply()

      {:error, changeset} ->
        {:noreply, assign(socket, :org_details_form, to_form(changeset, as: "org"))}
    end
  end

  # ---------------------------------------------------------------------------
  # Passo 2 — Primeiro condomínio
  # ---------------------------------------------------------------------------

  def handle_event("validate_condo", %{"condo" => params}, socket) do
    form =
      params
      |> Condo.change_condo()
      |> Map.put(:action, :validate)
      |> to_form(as: "condo")

    {:noreply, assign(socket, :condo_form, form)}
  end

  def handle_event("save_condo", %{"condo" => params}, socket) do
    user_id = socket.assigns.current_scope.user.id
    org = socket.assigns.org

    case Condo.create_condo(params, org, user_id) do
      {:ok, _condo} ->
        {:ok, org} = Condo.complete_onboarding(org)

        socket
        |> assign(:org, org)
        |> put_flash(:info, "Tudo pronto! Bem-vindo ao síndico.app.")
        |> push_navigate(to: ~p"/condominios")
        |> noreply()

      {:error, :condo_limit_reached} ->
        socket
        |> put_flash(:error, "Síndico morador pode ter apenas um condomínio.")
        |> noreply()

      {:error, changeset} ->
        {:noreply, assign(socket, :condo_form, to_form(changeset, as: "condo"))}
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers privados
  # ---------------------------------------------------------------------------

  defp assign_org_details_form(socket, org) do
    assign(socket, :org_details_form, to_form(Condo.change_org_details(org), as: "org"))
  end

  defp assign_condo_form(socket) do
    assign(socket, :condo_form, to_form(Condo.change_condo(), as: "condo"))
  end

  # ---------------------------------------------------------------------------
  # Render
  # ---------------------------------------------------------------------------

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <div class="min-h-screen bg-base-200 flex flex-col items-center justify-center p-4">
      <div class="mb-8 text-center">
        <.link href={~p"/"} class="text-xl font-bold text-base-content tracking-tight">
          síndico.app
        </.link>
        <p class="text-sm text-base-content/50 mt-1">Configure sua conta para começar</p>
      </div>

      <%!-- Indicador de progresso para administradora --%>
      <div :if={@org && @org.type == "property_manager"} class="flex items-center gap-3 mb-6">
        <div class={[
          "flex items-center gap-2 text-sm font-medium",
          if(@step == :org_details, do: "text-primary", else: "text-base-content/40")
        ]}>
          <span class={[
            "w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold",
            if(@step == :org_details,
              do: "bg-primary text-primary-content",
              else: "bg-base-300 text-base-content/40"
            )
          ]}>
            1
          </span>
          Dados da organização
        </div>
        <div class="w-8 h-px bg-base-300"></div>
        <div class={[
          "flex items-center gap-2 text-sm font-medium",
          if(@step == :first_condo, do: "text-primary", else: "text-base-content/40")
        ]}>
          <span class={[
            "w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold",
            if(@step == :first_condo,
              do: "bg-primary text-primary-content",
              else: "bg-base-300 text-base-content/40"
            )
          ]}>
            2
          </span>
          Primeiro condomínio
        </div>
      </div>

      <%!-- Passo 1: Dados da administradora --%>
      <div
        :if={@step == :org_details}
        class="card bg-base-100 border border-base-300 w-full max-w-lg shadow-sm"
      >
        <div class="card-body gap-5 p-8">
          <div class="space-y-1">
            <h2 class="text-lg font-bold text-base-content">Dados da sua administradora</h2>
            <p class="text-sm text-base-content/60">
              Precisamos dessas informações para emissão de cobranças e documentos fiscais.
            </p>
          </div>

          <.form
            for={@org_details_form}
            id="org_details_form"
            phx-change="validate_org_details"
            phx-submit="save_org_details"
            class="space-y-4"
            novalidate
          >
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <.input
                field={@org_details_form[:cnpj]}
                type="text"
                label="CNPJ"
                placeholder="00.000.000/0000-00"
                required
                phx-debounce="blur"
              />
              <.input
                field={@org_details_form[:phone]}
                type="tel"
                label="Telefone comercial"
                placeholder="(11) 99999-9999"
                required
                phx-debounce="blur"
              />
            </div>

            <div class="grid grid-cols-3 gap-4">
              <div class="col-span-2">
                <.input
                  field={@org_details_form[:street]}
                  type="text"
                  label="Rua / Avenida"
                  placeholder="Rua das Flores"
                  required
                  phx-debounce="blur"
                />
              </div>
              <.input
                field={@org_details_form[:street_number]}
                type="text"
                label="Número"
                placeholder="123"
                required
                phx-debounce="blur"
              />
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <.input
                field={@org_details_form[:complement]}
                type="text"
                label="Complemento"
                placeholder="Sala 4 (opcional)"
                phx-debounce="blur"
              />
              <.input
                field={@org_details_form[:neighborhood]}
                type="text"
                label="Bairro"
                placeholder="Centro"
                phx-debounce="blur"
              />
            </div>

            <div class="grid grid-cols-2 gap-4">
              <.input
                field={@org_details_form[:city]}
                type="text"
                label="Cidade"
                placeholder="São Paulo"
                required
                phx-debounce="blur"
              />
              <.input
                field={@org_details_form[:state]}
                type="text"
                label="Estado"
                placeholder="SP"
                required
                phx-debounce="blur"
              />
            </div>

            <.input
              field={@org_details_form[:zip_code]}
              type="text"
              label="CEP"
              placeholder="00000-000"
              required
              phx-debounce="blur"
            />

            <.button
              type="submit"
              phx-disable-with="Salvando..."
              class="btn btn-primary w-full min-h-[48px] text-base mt-2"
            >
              Continuar →
            </.button>
          </.form>
        </div>
      </div>

      <%!-- Passo 2: Primeiro condomínio --%>
      <div
        :if={@step == :first_condo}
        class="card bg-base-100 border border-base-300 w-full max-w-md shadow-sm"
      >
        <div class="card-body gap-5 p-8">
          <div class="space-y-1">
            <h2 class="text-lg font-bold text-base-content">
              {if @org && @org.type == "resident_syndic",
                do: "Cadastre seu condomínio",
                else: "Cadastre o primeiro condomínio"}
            </h2>
            <p class="text-sm text-base-content/60">
              {if @org && @org.type == "resident_syndic",
                do: "Você poderá configurar unidades e moradores depois.",
                else: "Você poderá adicionar mais condomínios depois."}
            </p>
          </div>

          <.form
            for={@condo_form}
            id="condo_form"
            phx-change="validate_condo"
            phx-submit="save_condo"
            class="space-y-4"
            novalidate
          >
            <.input
              field={@condo_form[:name]}
              type="text"
              label="Nome do condomínio"
              placeholder="Residencial das Flores"
              required
              phx-mounted={JS.focus()}
              phx-debounce="blur"
            />
            <.input
              field={@condo_form[:total_units]}
              type="number"
              label="Total de unidades"
              placeholder="48"
              phx-debounce="blur"
            />
            <.input
              field={@condo_form[:city]}
              type="text"
              label="Cidade"
              placeholder="São Paulo"
              phx-debounce="blur"
            />
            <.input
              field={@condo_form[:state]}
              type="text"
              label="Estado"
              placeholder="SP"
              phx-debounce="blur"
            />

            <.button
              type="submit"
              phx-disable-with="Salvando..."
              class="btn btn-primary w-full min-h-[48px] text-base mt-2"
            >
              Concluir cadastro
            </.button>
          </.form>
        </div>
      </div>
    </div>
    """
  end
end

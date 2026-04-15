defmodule AppWeb.AppLive.OrgMembers.Index do
  use AppWeb, :live_view

  alias App.Condo
  alias App.Accounts.Scope

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    # Apenas administradoras com role owner ou admin podem acessar
    unless Scope.can_manage_members?(scope) do
      {:ok, redirect(socket, to: ~p"/condominios")}
    else
      org = scope.org

      socket
      |> assign(:page_title, "Membros da organização")
      |> assign(:org, org)
      |> assign(:members, Condo.list_org_members(org))
      |> assign(:invite_form, to_form(%{}, as: "invite"))
      |> assign(:show_invite_modal, false)
      |> ok()
    end
  end

  @impl true
  def handle_event("open_invite", _, socket) do
    {:noreply, assign(socket, :show_invite_modal, true)}
  end

  def handle_event("close_invite", _, socket) do
    {:noreply,
     socket
     |> assign(:show_invite_modal, false)
     |> assign(:invite_form, to_form(%{}, as: "invite"))}
  end

  def handle_event("validate_invite", %{"invite" => params}, socket) do
    form =
      params
      |> validate_invite_params()
      |> Map.put(:action, :validate)
      |> to_form(as: "invite")

    {:noreply, assign(socket, :invite_form, form)}
  end

  def handle_event("send_invite", %{"invite" => %{"email" => email, "role" => role}}, socket) do
    case Condo.invite_org_member(socket.assigns.org, email, role) do
      {:ok, _user} ->
        socket
        |> put_flash(:info, "Convite enviado para #{email}.")
        |> assign(:show_invite_modal, false)
        |> assign(:invite_form, to_form(%{}, as: "invite"))
        |> assign(:members, Condo.list_org_members(socket.assigns.org))
        |> noreply()

      {:error, :not_allowed} ->
        {:noreply, put_flash(socket, :error, "Sua organização não permite convidar membros.")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Erro ao enviar convite. Verifique o e-mail.")}
    end
  end

  def handle_event("deactivate_member", %{"id" => id}, socket) do
    member =
      Enum.find(socket.assigns.members, &(&1.id == id))

    case member && Condo.deactivate_org_member(member) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "Membro removido.")
        |> assign(:members, Condo.list_org_members(socket.assigns.org))
        |> noreply()

      {:error, :cannot_remove_owner} ->
        {:noreply, put_flash(socket, :error, "Não é possível remover o proprietário da conta.")}

      _ ->
        {:noreply, put_flash(socket, :error, "Erro ao remover membro.")}
    end
  end

  defp validate_invite_params(params) do
    types = %{email: :string, role: :string}

    {%{}, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:email, :role], message: "obrigatório")
    |> Ecto.Changeset.validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
      message: "formato inválido"
    )
    |> Ecto.Changeset.validate_inclusion(:role, ~w(admin staff))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <div class="max-w-4xl mx-auto px-4 py-8 space-y-6">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-base-content">Membros da organização</h1>
          <p class="text-sm text-base-content/60 mt-1">{@org.name}</p>
        </div>
        <.button phx-click="open_invite" class="btn btn-primary btn-sm">
          Convidar membro
        </.button>
      </div>

      <%!-- Lista de membros --%>
      <div class="card bg-base-100 border border-base-300">
        <div class="divide-y divide-base-200">
          <div
            :for={member <- @members}
            class="flex items-center justify-between px-6 py-4"
          >
            <div class="flex items-center gap-3">
              <div class="avatar placeholder">
                <div class="bg-primary/10 text-primary rounded-full w-10 h-10">
                  <span class="text-sm font-bold">
                    {member.user.email |> String.first() |> String.upcase()}
                  </span>
                </div>
              </div>
              <div>
                <p class="text-sm font-semibold text-base-content">{member.user.email}</p>
                <p class="text-xs text-base-content/50">
                  {role_label(member.role)}
                </p>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <span class={[
                "badge badge-sm",
                if(member.role == "owner", do: "badge-primary", else: "badge-ghost")
              ]}>
                {role_label(member.role)}
              </span>
              <button
                :if={member.role != "owner"}
                phx-click="deactivate_member"
                phx-value-id={member.id}
                data-confirm="Tem certeza que deseja remover este membro?"
                class="btn btn-ghost btn-xs text-error"
              >
                Remover
              </button>
            </div>
          </div>

          <div :if={@members == []} class="px-6 py-10 text-center text-sm text-base-content/50">
            Nenhum membro cadastrado ainda.
          </div>
        </div>
      </div>
    </div>

    <%!-- Modal de convite --%>
    <div :if={@show_invite_modal} class="modal modal-open">
      <div class="modal-box max-w-sm">
        <h3 class="font-bold text-lg mb-4">Convidar novo membro</h3>

        <.form
          for={@invite_form}
          id="invite_form"
          phx-change="validate_invite"
          phx-submit="send_invite"
          class="space-y-4"
          novalidate
        >
          <.input
            field={@invite_form[:email]}
            type="email"
            label="E-mail do convidado"
            placeholder="colega@empresa.com"
            required
            phx-mounted={JS.focus()}
            phx-debounce="blur"
          />

          <div class="form-control gap-1.5">
            <label class="label py-0">
              <span class="label-text font-medium text-sm">Nível de acesso</span>
            </label>
            <select name={@invite_form[:role].name} class="select select-bordered select-sm w-full">
              <option value="staff">Colaborador — visualiza e opera</option>
              <option value="admin">Administrador — pode convidar outros</option>
            </select>
            <p
              :for={msg <- Enum.map(@invite_form[:role].errors, &translate_error(&1))}
              class="text-error text-xs mt-1"
            >
              {msg}
            </p>
          </div>

          <div class="modal-action mt-2">
            <button type="button" phx-click="close_invite" class="btn btn-ghost btn-sm">
              Cancelar
            </button>
            <.button
              type="submit"
              phx-disable-with="Enviando..."
              class="btn btn-primary btn-sm"
            >
              Enviar convite
            </.button>
          </div>
        </.form>
      </div>
      <div class="modal-backdrop" phx-click="close_invite"></div>
    </div>
    """
  end

  defp role_label("owner"), do: "Proprietário"
  defp role_label("admin"), do: "Administrador"
  defp role_label("staff"), do: "Colaborador"
  defp role_label(_), do: "Membro"
end

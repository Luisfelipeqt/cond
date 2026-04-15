defmodule AppWeb.AppLive.Condominios.Index do
  use AppWeb, :live_view

  alias App.Condo
  alias App.Condo.Condo, as: CondoSchema

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id
    condos = Condo.list_condos_for_user(user_id)

    socket
    |> assign(:page_title, "Meus Condomínios")
    |> assign(:condos, condos)
    |> ok()
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket
    |> apply_action(socket.assigns.live_action)
    |> noreply()
  end

  defp apply_action(socket, :new) do
    socket
    |> assign(:page_title, "Novo Condomínio")
    |> assign(:form, to_form(Condo.change_condo(%CondoSchema{})))
  end

  defp apply_action(socket, :index) do
    socket
    |> assign(:page_title, "Meus Condomínios")
    |> assign(:form, nil)
  end

  @impl true
  def handle_event("validate", %{"condo" => params}, socket) do
    form =
      %CondoSchema{}
      |> Condo.change_condo(params)
      |> Map.put(:action, :validate)
      |> to_form()

    socket |> assign(:form, form) |> noreply()
  end

  def handle_event("save", %{"condo" => params}, socket) do
    user_id = socket.assigns.current_scope.user.id

    case Condo.create_condo(params, user_id) do
      {:ok, condo} ->
        socket
        |> put_flash(:info, "Condomínio criado com sucesso!")
        |> push_navigate(to: ~p"/condominios/#{condo.id}/assembleias")
        |> noreply()

      {:error, changeset} ->
        socket |> assign(:form, to_form(changeset)) |> noreply()
    end
  end

  def handle_event("cancel", _params, socket) do
    socket |> push_patch(to: ~p"/condominios") |> noreply()
  end
end

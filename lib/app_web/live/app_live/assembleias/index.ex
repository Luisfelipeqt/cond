defmodule AppWeb.AppLive.Assembleias.Index do
  use AppWeb, :live_view

  alias App.Assembly
  alias App.Assembly.Meeting
  alias App.Condo

  @impl true
  def mount(%{"condo_id" => condo_id}, _session, socket) do
    condo = Condo.get_condo!(condo_id)

    socket
    |> assign(:condo, condo)
    |> assign(:meetings, Assembly.list_meetings(condo_id))
    |> assign(:filter, "all")
    |> assign(:page_title, "Assembleias & Atas")
    |> ok()
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filter = Map.get(params, "filter", "all")

    socket
    |> assign(:filter, filter)
    |> apply_action(socket.assigns.live_action, params)
    |> noreply()
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nova Assembleia")
    |> assign(:meeting, %Meeting{})
    |> assign(:form, to_form(Assembly.change_meeting(%Meeting{})))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Assembleias & Atas")
    |> assign(:meeting, nil)
    |> assign(:form, nil)
  end

  @impl true
  def handle_event("save", %{"meeting" => params}, socket) do
    condo = socket.assigns.condo
    user_id = socket.assigns.current_scope.user.id

    params =
      params
      |> Map.put("condo_id", condo.id)
      |> Map.put("created_by_id", user_id)

    case Assembly.create_meeting(params) do
      {:ok, meeting} ->
        socket
        |> put_flash(:info, "Assembleia criada com sucesso.")
        |> push_navigate(to: ~p"/condominios/#{condo.id}/assembleias/#{meeting.id}")
        |> noreply()

      {:error, changeset} ->
        socket |> assign(:form, to_form(changeset)) |> noreply()
    end
  end

  def handle_event("validate", %{"meeting" => params}, socket) do
    changeset =
      socket.assigns.meeting
      |> Assembly.change_meeting(params)
      |> Map.put(:action, :validate)

    socket |> assign(:form, to_form(changeset)) |> noreply()
  end

  def handle_event("cancel", _params, socket) do
    socket
    |> push_patch(to: ~p"/condominios/#{socket.assigns.condo.id}/assembleias")
    |> noreply()
  end

  # Helpers usados no template
  def meeting_type_label("ago"), do: "AGO"
  def meeting_type_label("age"), do: "AGE"
  def meeting_type_label("council"), do: "Conselho"
  def meeting_type_label(_), do: "Outro"

  def meeting_status_label("scheduled"), do: "Agendada"
  def meeting_status_label("held"), do: "Realizada"
  def meeting_status_label("minutes_draft"), do: "Ata em rascunho"
  def meeting_status_label("minutes_approved"), do: "Ata aprovada"
  def meeting_status_label("registered"), do: "Registrada"
  def meeting_status_label("cancelled"), do: "Cancelada"
  def meeting_status_label(_), do: "—"

  def meeting_status_class("scheduled"), do: "badge-info"
  def meeting_status_class("held"), do: "badge-warning"
  def meeting_status_class("minutes_draft"), do: "badge-warning"
  def meeting_status_class("minutes_approved"), do: "badge-success"
  def meeting_status_class("registered"), do: "badge-neutral"
  def meeting_status_class("cancelled"), do: "badge-error"
  def meeting_status_class(_), do: "badge-ghost"
end

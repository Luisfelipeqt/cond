defmodule AppWeb.AppLive.Unidades.Index do
  use AppWeb, :live_view

  alias App.Condo
  alias App.Condo.Unit

  @impl true
  def mount(%{"condo_id" => condo_id}, _session, socket) do
    condo = Condo.get_condo!(condo_id)

    socket
    |> assign(:condo, condo)
    |> assign(:units, Condo.list_units_for_condo(condo_id))
    |> assign(:page_title, "Unidades")
    |> assign(:unit, nil)
    |> assign(:form, nil)
    |> ok()
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket
    |> apply_action(socket.assigns.live_action, params)
    |> noreply()
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Unidades")
    |> assign(:unit, nil)
    |> assign(:form, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nova Unidade")
    |> assign(:unit, %Unit{})
    |> assign(:form, to_form(Condo.change_unit()))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    unit = Condo.get_unit!(id)

    socket
    |> assign(:page_title, "Editar Unidade")
    |> assign(:unit, unit)
    |> assign(:form, to_form(Condo.change_unit(unit, %{})))
  end

  @impl true
  def handle_event("validate", %{"unit" => params}, socket) do
    changeset =
      Condo.change_unit(socket.assigns.unit, params)
      |> Map.put(:action, :validate)

    socket |> assign(:form, to_form(changeset)) |> noreply()
  end

  def handle_event("save", %{"unit" => params}, socket) do
    condo = socket.assigns.condo

    params = Map.put(params, "condo_id", condo.id)

    case socket.assigns.live_action do
      :new -> create_unit(socket, params)
      :edit -> update_unit(socket, params)
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    unit = Condo.get_unit!(id)

    case Condo.delete_unit(unit) do
      {:ok, _} ->
        socket
        |> assign(:units, Condo.list_units_for_condo(socket.assigns.condo.id))
        |> put_flash(:info, "Unidade removida.")
        |> noreply()

      {:error, _} ->
        socket
        |> put_flash(:error, "Não foi possível remover — unidade pode ter presenças vinculadas.")
        |> noreply()
    end
  end

  def handle_event("cancel", _params, socket) do
    socket
    |> push_patch(to: ~p"/condominios/#{socket.assigns.condo.id}/unidades")
    |> noreply()
  end

  defp create_unit(socket, params) do
    case Condo.create_unit(params) do
      {:ok, _unit} ->
        socket
        |> assign(:units, Condo.list_units_for_condo(socket.assigns.condo.id))
        |> put_flash(:info, "Unidade criada com sucesso.")
        |> push_patch(to: ~p"/condominios/#{socket.assigns.condo.id}/unidades")
        |> noreply()

      {:error, changeset} ->
        socket |> assign(:form, to_form(changeset)) |> noreply()
    end
  end

  defp update_unit(socket, params) do
    case Condo.update_unit(socket.assigns.unit, params) do
      {:ok, _unit} ->
        socket
        |> assign(:units, Condo.list_units_for_condo(socket.assigns.condo.id))
        |> put_flash(:info, "Unidade atualizada.")
        |> push_patch(to: ~p"/condominios/#{socket.assigns.condo.id}/unidades")
        |> noreply()

      {:error, changeset} ->
        socket |> assign(:form, to_form(changeset)) |> noreply()
    end
  end

  def unit_type_label("apartment"), do: "Apartamento"
  def unit_type_label("house"), do: "Casa"
  def unit_type_label("commercial"), do: "Comercial"
  def unit_type_label("parking"), do: "Estacionamento"
  def unit_type_label(_), do: "—"
end

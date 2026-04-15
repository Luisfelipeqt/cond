defmodule AppWeb.HomeLive.Index do
  use AppWeb, :live_view
  import AppWeb.HomeLive.Components
  alias App.Marketing

  def mount(_params, _session, socket) do
    changeset = Marketing.change_contact()

    socket
    |> assign(:page_title, "síndico.app")
    |> assign(:form, to_form(changeset, as: "contact"))
    |> assign(:contact_submitted, false)
    |> ok()
  end

  def handle_params(%{"to" => section}, _uri, socket) do
    socket
    |> push_event("scroll-to", %{id: section})
    |> push_patch(to: ~p"/")
    |> noreply()
  end

  def handle_params(_params, _uri, socket), do: noreply(socket)

  def handle_event("validate_contact", %{"contact" => params}, socket) do
    params
    |> Marketing.change_contact()
    |> Map.put(:action, :validate)
    |> then(&assign(socket, :form, to_form(&1, as: "contact")))
    |> noreply()
  end

  def handle_event("submit_contact", %{"contact" => params}, socket) do
    case Marketing.create_contact(params) do
      {:ok, _contact} ->
        socket
        |> assign(:contact_submitted, true)
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:form, to_form(changeset, as: "contact"))
        |> noreply()
    end
  end
end

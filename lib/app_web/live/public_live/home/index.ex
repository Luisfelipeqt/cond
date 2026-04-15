defmodule AppWeb.PublicLive.Home.Index do
  use AppWeb, :live_view
  import AppWeb.PublicLive.Components.Marketing

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "síndico.app")
    |> ok()
  end

  def handle_params(%{"to" => section}, _uri, socket) do
    socket
    |> push_event("scroll-to", %{id: section})
    |> push_patch(to: ~p"/")
    |> noreply()
  end

  def handle_params(_params, _uri, socket), do: noreply(socket)
end

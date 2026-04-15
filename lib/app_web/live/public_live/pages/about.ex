defmodule AppWeb.PublicLive.Pages.About do
  use AppWeb, :live_view
  import AppWeb.HomeLive.Components, only: [navbar: 1]

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Sobre nós")
    |> ok()
  end
end

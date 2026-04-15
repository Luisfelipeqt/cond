defmodule AppWeb.PublicLive.Pages.Privacy do
  use AppWeb, :live_view
  import AppWeb.HomeLive.Components, only: [navbar: 1]

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Política de Privacidade")
    |> ok()
  end
end

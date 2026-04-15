defmodule AppWeb.PublicLive.Pages.ForYou do
  use AppWeb, :live_view
  import AppWeb.PublicLive.Components.Marketing, only: [navbar: 1]

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Para você")
    |> ok()
  end
end

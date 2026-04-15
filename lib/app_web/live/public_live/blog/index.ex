defmodule AppWeb.PublicLive.Blog.Index do
  use AppWeb, :live_view
  import AppWeb.HomeLive.Components, only: [navbar: 1]
  alias App.Blog

  def mount(_params, _session, socket) do
    socket
    |> assign(:posts, Blog.list_posts())
    |> assign(:page_title, "Blog")
    |> ok()
  end
end

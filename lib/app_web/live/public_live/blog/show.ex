defmodule AppWeb.PublicLive.Blog.Show do
  use AppWeb, :live_view
  import AppWeb.HomeLive.Components, only: [navbar: 1]
  alias App.Blog

  def mount(%{"slug" => slug}, _session, socket) do
    case Blog.get_post(slug) do
      {:ok, post} ->
        socket
        |> assign(:post, post)
        |> assign(:page_title, post.title)
        |> ok()

      {:error, :not_found} ->
        socket
        |> put_flash(:error, "Artigo não encontrado.")
        |> redirect(to: ~p"/blog")
        |> ok()
    end
  end
end

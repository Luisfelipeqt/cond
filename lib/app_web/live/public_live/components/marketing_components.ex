defmodule AppWeb.PublicLive.Components.Marketing do
  use AppWeb, :html

  # Seções estáticas da home: cada arquivo .html.heex vira uma função component/1
  embed_templates "home_sections/*"

  # Navbar compartilhada entre todas as páginas de marketing.
  # on_home_page: true  → itens de Produto usam smooth-scroll (sem mudar URL)
  # on_home_page: false → itens de Produto usam href para /#secao
  attr :on_home_page, :boolean, default: false

  def navbar(assigns) do
    ~H"""
    <%!-- SKIP LINK --%>
    <a
      href="#conteudo"
      class="sr-only focus:not-sr-only focus:absolute focus:top-3 focus:left-3 focus:z-[200] btn btn-primary btn-sm"
    >
      Ir para o conteúdo principal
    </a>

    <%!-- NAVBAR --%>
    <nav
      class="navbar bg-base-100/80 backdrop-blur-sm border-b border-base-300 sticky top-0 z-50 px-4 md:px-10"
      aria-label="Navegação principal"
    >
      <div class="navbar-start">
        <.link
          navigate={~p"/"}
          class="text-base font-bold text-base-content tracking-tight focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary rounded"
        >
          síndico.app
        </.link>
      </div>

      <%!-- Links centrais — desktop --%>
      <div class="navbar-center hidden lg:flex items-center gap-0.5">
        <%!-- Dropdown Produto --%>
        <div class="dropdown dropdown-hover">
          <button
            tabindex="0"
            class="btn btn-ghost btn-sm text-sm text-base-content/60 hover:text-base-content gap-1"
          >
            Produto
            <svg
              class="w-3 h-3 opacity-50"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2.5"
              aria-hidden="true"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />
            </svg>
          </button>
          <ul class="dropdown-content menu menu-sm bg-base-100 border border-base-300 rounded-xl shadow-xl w-52 p-1.5 mt-0 z-50">
            <li>
              <button
                :if={@on_home_page}
                phx-click={JS.dispatch("smooth-scroll", detail: %{id: "como-funciona"})}
                class="text-sm py-2"
              >
                Como funciona
              </button>
              <.link :if={!@on_home_page} navigate={~p"/?to=como-funciona"} class="text-sm py-2">
                Como funciona
              </.link>
            </li>
            <li>
              <button
                :if={@on_home_page}
                phx-click={JS.dispatch("smooth-scroll", detail: %{id: "plataforma"})}
                class="text-sm py-2"
              >
                Plataforma
              </button>
              <.link :if={!@on_home_page} navigate={~p"/?to=plataforma"} class="text-sm py-2">
                Plataforma
              </.link>
            </li>
            <li>
              <button
                :if={@on_home_page}
                phx-click={JS.dispatch("smooth-scroll", detail: %{id: "precos"})}
                class="text-sm py-2"
              >
                Preços
              </button>
              <.link :if={!@on_home_page} navigate={~p"/?to=precos"} class="text-sm py-2">
                Preços
              </.link>
            </li>
          </ul>
        </div>

        <%!-- Dropdown Soluções --%>
        <div class="dropdown dropdown-hover">
          <button
            tabindex="0"
            class="btn btn-ghost btn-sm text-sm text-base-content/60 hover:text-base-content gap-1"
          >
            Soluções
            <svg
              class="w-3 h-3 opacity-50"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2.5"
              aria-hidden="true"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />
            </svg>
          </button>
          <ul class="dropdown-content menu menu-sm bg-base-100 border border-base-300 rounded-xl shadow-xl w-52 p-1.5 mt-0 z-50">
            <li>
              <.link navigate={~p"/para-voce"} class="text-sm py-2">
                Para você
              </.link>
            </li>
            <li>
              <.link navigate={~p"/para-seu-negocio"} class="text-sm py-2">
                Para seu negócio
              </.link>
            </li>
          </ul>
        </div>

        <.link
          navigate={~p"/blog"}
          class="btn btn-ghost btn-sm text-sm text-base-content/60 hover:text-base-content"
        >
          Blog
        </.link>

        <.link
          navigate={~p"/sobre-nos"}
          class="btn btn-ghost btn-sm text-sm text-base-content/60 hover:text-base-content"
        >
          Sobre nós
        </.link>
      </div>

      <div class="navbar-end gap-2">
        <.link navigate={~p"/users/log-in"} class="btn btn-ghost btn-sm hidden lg:flex">
          Entrar
        </.link>
        <button
          :if={@on_home_page}
          phx-click={JS.dispatch("smooth-scroll", detail: %{id: "contato"})}
          class="btn btn-primary btn-sm hidden sm:flex"
        >
          Falar com a equipe
        </button>
        <.link
          :if={!@on_home_page}
          navigate={~p"/?to=contato"}
          class="btn btn-primary btn-sm hidden sm:flex"
        >
          Falar com a equipe
        </.link>
        <Layouts.theme_toggle />

        <%!-- Menu hamburger — mobile/tablet --%>
        <div class="dropdown dropdown-end lg:hidden">
          <button
            tabindex="0"
            class="btn btn-ghost btn-sm min-h-[44px] min-w-[44px]"
            aria-label="Abrir menu"
            aria-haspopup="true"
          >
            <svg
              class="w-5 h-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="1.5"
              aria-hidden="true"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
              />
            </svg>
          </button>
          <ul
            tabindex="0"
            class="menu menu-sm dropdown-content bg-base-100 border border-base-300 rounded-2xl z-50 mt-3 w-64 p-3 shadow-xl"
            role="menu"
          >
            <%!-- Grupo: Produto --%>
            <li
              class="menu-title text-xs text-base-content/40 uppercase tracking-widest px-2 pt-1 pb-0.5"
              role="none"
            >
              Produto
            </li>
            <li role="none">
              <button
                :if={@on_home_page}
                phx-click={JS.dispatch("smooth-scroll", detail: %{id: "como-funciona"})}
                class="py-2.5 text-sm w-full text-left"
                role="menuitem"
              >
                Como funciona
              </button>
              <.link
                :if={!@on_home_page}
                navigate={~p"/?to=como-funciona"}
                class="py-2.5 text-sm"
                role="menuitem"
              >
                Como funciona
              </.link>
            </li>
            <li role="none">
              <button
                :if={@on_home_page}
                phx-click={JS.dispatch("smooth-scroll", detail: %{id: "plataforma"})}
                class="py-2.5 text-sm w-full text-left"
                role="menuitem"
              >
                Plataforma
              </button>
              <.link
                :if={!@on_home_page}
                navigate={~p"/?to=plataforma"}
                class="py-2.5 text-sm"
                role="menuitem"
              >
                Plataforma
              </.link>
            </li>
            <li role="none">
              <button
                :if={@on_home_page}
                phx-click={JS.dispatch("smooth-scroll", detail: %{id: "precos"})}
                class="py-2.5 text-sm w-full text-left"
                role="menuitem"
              >
                Preços
              </button>
              <.link
                :if={!@on_home_page}
                navigate={~p"/?to=precos"}
                class="py-2.5 text-sm"
                role="menuitem"
              >
                Preços
              </.link>
            </li>

            <li class="divider my-1" role="none"></li>

            <%!-- Grupo: Soluções --%>
            <li
              class="menu-title text-xs text-base-content/40 uppercase tracking-widest px-2 pb-0.5"
              role="none"
            >
              Soluções
            </li>
            <li role="none">
              <.link navigate={~p"/para-voce"} class="py-2.5 text-sm" role="menuitem">
                Para você
              </.link>
            </li>
            <li role="none">
              <.link navigate={~p"/para-seu-negocio"} class="py-2.5 text-sm" role="menuitem">
                Para seu negócio
              </.link>
            </li>
            <li class="divider my-1" role="none"></li>

            <li role="none">
              <.link navigate={~p"/blog"} class="py-2.5 text-sm" role="menuitem">
                Blog
              </.link>
            </li>
            <li role="none">
              <.link navigate={~p"/sobre-nos"} class="py-2.5 text-sm" role="menuitem">
                Sobre nós
              </.link>
            </li>

            <li class="divider my-1" role="none"></li>

            <li role="none">
              <button
                :if={@on_home_page}
                phx-click={JS.dispatch("smooth-scroll", detail: %{id: "contato"})}
                class="btn btn-primary btn-sm w-full mt-1"
                role="menuitem"
              >
                Falar com a equipe
              </button>
              <.link
                :if={!@on_home_page}
                navigate={~p"/?to=contato"}
                class="btn btn-primary btn-sm w-full mt-1"
                role="menuitem"
              >
                Falar com a equipe
              </.link>
            </li>
            <li role="none">
              <.link
                navigate={~p"/users/log-in"}
                class="btn btn-ghost btn-sm w-full mt-1"
                role="menuitem"
              >
                Entrar
              </.link>
            </li>
          </ul>
        </div>
      </div>
    </nav>
    """
  end
end

defmodule AppWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use AppWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  attr :flash, :map, required: true

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  # Condomínio ativo no contexto da sessão (nil = nenhum selecionado)
  attr :condo, :any, default: nil

  slot :inner_block, required: true

  def private_app(assigns) do
    ~H"""
    <div id="app-drawer" class="drawer lg:drawer-open min-h-screen">
      <input id="sidebar-input" type="checkbox" class="drawer-toggle" />

      <%!-- ── Main content ── --%>
      <div class="drawer-content flex flex-col min-h-screen bg-base-100">
        <%!-- Header --%>
        <header class="sticky top-0 z-30 bg-base-100/80 backdrop-blur-sm border-b border-base-300 shrink-0">
          <div class="navbar px-4 min-h-14 gap-2">
            <label
              for="sidebar-input"
              class="btn btn-ghost btn-square btn-sm lg:hidden"
              aria-label="Abrir menu"
            >
              <.icon name="hero-bars-3" class="size-5" />
            </label>
            <button
              class="hidden lg:flex btn btn-ghost btn-square btn-sm"
              phx-click={JS.toggle_class("lg:drawer-open", to: "#app-drawer")}
              aria-label="Recolher menu"
            >
              <.icon name="hero-bars-3" class="size-5" />
            </button>

            <%!-- Breadcrumb do condomínio ativo no header (mobile) --%>
            <div :if={@condo} class="flex-1 flex items-center gap-1.5 lg:hidden min-w-0">
              <span class="text-xs text-base-content/40 truncate">{@condo.name}</span>
            </div>

            <div class="flex-1 hidden lg:block" />

            <div class="flex items-center gap-2">
              <.theme_toggle />
            </div>
          </div>
        </header>

        <%!-- Page content --%>
        <main class="flex-1 p-4 lg:p-8">
          {render_slot(@inner_block)}
        </main>
      </div>

      <%!-- ── Sidebar ── --%>
      <div class="drawer-side z-40">
        <label for="sidebar-input" aria-label="Fechar menu" class="drawer-overlay" />

        <aside class="w-64 min-h-full bg-base-200 border-r border-base-300 flex flex-col">
          <%!-- Logo --%>
          <div class="flex items-center justify-between px-4 h-14 border-b border-base-300 shrink-0">
            <.link navigate={~p"/"} class="flex-1 flex items-center gap-2">
              <span class="text-base font-bold text-base-content tracking-tight">síndico.app</span>
            </.link>
            <label
              for="sidebar-input"
              class="btn btn-ghost btn-xs btn-square lg:hidden shrink-0"
              aria-label="Fechar menu"
            >
              <.icon name="hero-x-mark" class="size-4" />
            </label>
          </div>

          <%!-- ── Seletor de Condomínio ── --%>
          <div class="p-3 border-b border-base-300 shrink-0">
            <%!-- Nenhum condomínio selecionado --%>
            <div :if={is_nil(@condo)}>
              <.link
                navigate={~p"/condominios"}
                class="flex items-center gap-3 px-3 py-2.5 rounded-xl bg-warning/10 border border-warning/20 hover:bg-warning/15 transition-colors group"
              >
                <div class="w-8 h-8 rounded-lg bg-warning/20 flex items-center justify-center shrink-0">
                  <.icon name="hero-building-office-2" class="size-4 text-warning" />
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-xs font-semibold text-warning">Selecionar condomínio</p>
                  <p class="text-xs text-base-content/40">Escolha para começar</p>
                </div>
                <.icon name="hero-chevron-right" class="size-3.5 text-warning/60 shrink-0" />
              </.link>
            </div>

            <%!-- Condomínio selecionado --%>
            <div :if={@condo} class="space-y-1.5">
              <div class="flex items-center gap-3 px-3 py-2.5 rounded-xl bg-primary/10 border border-primary/15">
                <div class="w-8 h-8 rounded-lg bg-primary/20 flex items-center justify-center shrink-0">
                  <.icon name="hero-building-office-2" class="size-4 text-primary" />
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-xs font-semibold text-base-content truncate">{@condo.name}</p>
                  <p :if={@condo.city} class="text-xs text-base-content/40 truncate">
                    {@condo.city}{if @condo.state, do: ", #{@condo.state}"}
                  </p>
                </div>
              </div>
              <.link
                navigate={~p"/condominios"}
                class="flex items-center justify-center gap-1.5 py-1 rounded-lg text-xs text-base-content/40 hover:text-base-content/70 hover:bg-base-300 transition-colors"
              >
                <.icon name="hero-arrows-right-left" class="size-3" /> Trocar condomínio
              </.link>
            </div>
          </div>

          <%!-- ── Navegação --%>
          <nav class="flex-1 p-3 space-y-0.5 overflow-y-auto">
            <%!-- Módulos do condomínio (só visíveis quando um está selecionado) --%>
            <div :if={@condo} class="space-y-0.5">
              <p class="px-3 pt-1 pb-1.5 text-xs font-semibold text-base-content/30 uppercase tracking-widest">
                Módulos
              </p>
              <.private_nav_item
                icon="hero-squares-2x2"
                label="Painel"
                href={"/condominios/#{@condo.id}"}
                disabled
              />
              <.private_nav_item
                icon="hero-home"
                label="Unidades"
                href={~p"/condominios/#{@condo.id}/unidades"}
              />
              <.private_nav_item
                icon="hero-document-text"
                label="Assembleias & Atas"
                href={~p"/condominios/#{@condo.id}/assembleias"}
              />
              <.private_nav_item
                icon="hero-megaphone"
                label="Comunicados"
                href={"/condominios/#{@condo.id}/comunicados"}
                disabled
              />
              <.private_nav_item
                icon="hero-exclamation-triangle"
                label="Ocorrências"
                href={"/condominios/#{@condo.id}/ocorrencias"}
                disabled
              />
              <.private_nav_item
                icon="hero-document-magnifying-glass"
                label="Cotações"
                href={"/condominios/#{@condo.id}/cotacoes"}
                disabled
              />
              <.private_nav_item
                icon="hero-folder-open"
                label="Documentos"
                href={"/condominios/#{@condo.id}/documentos"}
                disabled
              />
            </div>

            <%!-- Sem condomínio: mostra só o atalho para a lista --%>
            <div :if={is_nil(@condo)} class="space-y-0.5">
              <p class="px-3 pt-1 pb-1.5 text-xs font-semibold text-base-content/30 uppercase tracking-widest">
                Início
              </p>
              <.private_nav_item
                icon="hero-building-office-2"
                label="Meus Condomínios"
                href={~p"/condominios"}
              />
            </div>

            <%!-- Separador --%>
            <div class="pt-2">
              <div class="border-t border-base-300 mb-2" />
              <p class="px-3 pb-1.5 text-xs font-semibold text-base-content/30 uppercase tracking-widest">
                Conta
              </p>
              <.private_nav_item
                icon="hero-cog-6-tooth"
                label="Configurações"
                href={~p"/users/settings"}
              />
            </div>
          </nav>

          <%!-- User section --%>
          <div class="p-3 border-t border-base-300 shrink-0">
            <div :if={@current_scope} class="flex items-center gap-3 px-2 py-2 mb-1 min-w-0">
              <div class="size-8 rounded-full bg-primary/15 text-primary flex items-center justify-center text-xs font-bold shrink-0">
                {String.first(@current_scope.user.email) |> String.upcase()}
              </div>
              <span class="text-xs text-base-content/70 truncate font-medium">
                {@current_scope.user.email}
              </span>
            </div>
            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="flex items-center gap-2.5 px-2 py-2 rounded-lg text-sm text-base-content/60 hover:text-error hover:bg-base-300 transition-colors duration-150 w-full"
            >
              <.icon name="hero-arrow-right-on-rectangle" class="size-4 shrink-0" /> Sair
            </.link>
          </div>
        </aside>
      </div>
    </div>
    <.flash_group flash={@flash} />
    """
  end

  attr :icon, :string, required: true
  attr :label, :string, required: true
  attr :href, :string, required: true
  attr :disabled, :boolean, default: false

  defp private_nav_item(assigns) do
    ~H"""
    <%= if @disabled do %>
      <div class="flex items-center gap-2.5 px-3 py-2.5 rounded-lg text-sm font-medium
                  text-base-content/30 cursor-not-allowed select-none">
        <.icon name={@icon} class="size-4 shrink-0" />
        <span class="flex-1">{@label}</span>
        <span class="text-xs bg-base-300 text-base-content/30 px-1.5 py-0.5 rounded font-normal">
          Em breve
        </span>
      </div>
    <% else %>
      <.link
        navigate={@href}
        class="flex items-center gap-2.5 px-3 py-2.5 rounded-lg text-sm font-medium
               text-base-content/70 hover:text-base-content hover:bg-base-300
               transition-colors duration-150 group"
      >
        <.icon
          name={@icon}
          class="size-4 shrink-0 group-hover:text-primary transition-colors duration-150"
        />
        {@label}
      </.link>
    <% end %>
    """
  end

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar bg-base-100/80 backdrop-blur-sm border-b border-base-300 sticky top-0 z-50 px-4 sm:px-6">
      <div class="navbar-start">
        <.link href={~p"/"} class="text-sm font-bold text-base-content tracking-tight">
          síndico.app
        </.link>
      </div>
      <div class="navbar-end gap-2">
        <%= if @current_scope do %>
          <span class="text-sm text-base-content/50 hidden sm:block mr-1">
            {@current_scope.user.email}
          </span>
          <.link href={~p"/users/log-out"} method="delete" class="btn btn-ghost btn-sm">
            Sair
          </.link>
        <% else %>
          <.link href={~p"/users/log-in"} class="btn btn-ghost btn-sm">Entrar</.link>
          <.link href={~p"/users/register"} class="btn btn-primary btn-sm">Criar conta</.link>
        <% end %>
        <.theme_toggle />
      </div>
    </header>

    <main class="px-4 py-10 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end

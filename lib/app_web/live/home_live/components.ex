defmodule AppWeb.HomeLive.Components do
  use AppWeb, :html

  # Seções estáticas: cada arquivo .html.heex vira uma função component/1
  embed_templates "components/*"

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
            <svg class="w-3 h-3 opacity-50" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
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
            <svg class="w-3 h-3 opacity-50" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
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

        <.link navigate={~p"/blog"} class="btn btn-ghost btn-sm text-sm text-base-content/60 hover:text-base-content">
          Blog
        </.link>

        <.link navigate={~p"/sobre-nos"} class="btn btn-ghost btn-sm text-sm text-base-content/60 hover:text-base-content">
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
              <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
            </svg>
          </button>
          <ul
            tabindex="0"
            class="menu menu-sm dropdown-content bg-base-100 border border-base-300 rounded-2xl z-50 mt-3 w-64 p-3 shadow-xl"
            role="menu"
          >
            <%!-- Grupo: Produto --%>
            <li class="menu-title text-xs text-base-content/40 uppercase tracking-widest px-2 pt-1 pb-0.5" role="none">
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
              <.link :if={!@on_home_page} navigate={~p"/?to=como-funciona"} class="py-2.5 text-sm" role="menuitem">
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
              <.link :if={!@on_home_page} navigate={~p"/?to=plataforma"} class="py-2.5 text-sm" role="menuitem">
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
              <.link :if={!@on_home_page} navigate={~p"/?to=precos"} class="py-2.5 text-sm" role="menuitem">
                Preços
              </.link>
            </li>

            <li class="divider my-1" role="none"></li>

            <%!-- Grupo: Soluções --%>
            <li class="menu-title text-xs text-base-content/40 uppercase tracking-widest px-2 pb-0.5" role="none">
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

  # Seção de contato declarada explicitamente pois precisa de assigns dinâmicos
  attr :form, Phoenix.HTML.Form, required: true
  attr :contact_submitted, :boolean, default: false

  def contact(assigns) do
    ~H"""
    <section
      class="py-14 px-5 md:py-24 md:px-6 bg-base-200/50"
      id="contato"
      aria-labelledby="contato-heading"
    >
      <div class="max-w-6xl mx-auto">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-14 items-start">
          <%!-- Copy --%>
          <div class="space-y-7 order-2 lg:order-1">
            <div>
              <div
                class="inline-flex items-center gap-2 bg-primary/10 text-primary rounded-full px-4 py-1.5 mb-5 text-xs font-semibold uppercase tracking-widest"
                aria-hidden="true"
              >
                Fale com a equipe
              </div>
              <h2
                id="contato-heading"
                class="text-2xl sm:text-3xl md:text-4xl font-bold text-base-content mb-3 leading-tight"
              >
                Pronto para deixar o WhatsApp e a planilha no passado?
              </h2>
              <p class="text-base-content/60 leading-relaxed text-sm sm:text-base">
                Preencha o formulário e nossa equipe entrará em contato para apresentar a plataforma, tirar dúvidas e montar o plano ideal para a sua operação.
              </p>
            </div>

            <ul class="space-y-4" aria-label="O que esperar após o contato">
              <li
                :for={
                  {icon_path, title, desc} <- [
                    {"M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z", "Retorno em até 24 horas",
                     "Entraremos em contato por telefone ou email no próximo dia útil."},
                    {"M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
                     "Demo personalizada e gratuita",
                     "Mostramos a plataforma com exemplos da sua realidade operacional."},
                    {"M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z",
                     "Seus dados protegidos", "Não compartilhamos seus dados com terceiros. Nunca."}
                  ]
                }
                class="flex items-start gap-4"
              >
                <div
                  class="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center flex-shrink-0"
                  aria-hidden="true"
                >
                  <svg
                    class="w-5 h-5 text-primary"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                    stroke-width="1.5"
                    aria-hidden="true"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d={icon_path} />
                  </svg>
                </div>
                <div>
                  <p class="font-semibold text-base-content text-sm">{title}</p>
                  <p class="text-sm text-base-content/60">{desc}</p>
                </div>
              </li>
            </ul>
          </div>

          <%!-- Formulário --%>
          <div class="card bg-base-100 border border-base-300 shadow-sm order-1 lg:order-2">
            <div class="card-body p-6 md:p-8">
              <div :if={@contact_submitted} class="flex flex-col items-center text-center py-8 gap-4">
                <div class="w-16 h-16 rounded-full bg-success/10 flex items-center justify-center">
                  <svg
                    class="w-8 h-8 text-success"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                    stroke-width="1.5"
                    aria-hidden="true"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </div>
                <h3 class="text-xl font-bold text-base-content">Recebemos o seu contato!</h3>
                <p class="text-sm text-base-content/60 max-w-xs">
                  Nossa equipe entrará em contato em até 24 horas. Fique de olho no seu e-mail e telefone.
                </p>
              </div>

              <div :if={!@contact_submitted}>
                <h3 class="text-lg font-bold text-base-content mb-1">Entre em contato</h3>
                <p class="text-sm text-base-content/50 mb-6">
                  Preencha os dados abaixo e retornaremos em breve.
                </p>
                <.form
                  for={@form}
                  id="contact_form"
                  phx-change="validate_contact"
                  phx-submit="submit_contact"
                  class="space-y-4"
                  novalidate
                >
                  <.input
                    field={@form[:name]}
                    type="text"
                    label="Nome completo"
                    placeholder="João da Silva"
                    required
                    autocomplete="name"
                    phx-mounted={JS.focus()}
                  />
                  <.input
                    field={@form[:email]}
                    type="email"
                    label="E-mail"
                    placeholder="joao@email.com"
                    required
                    autocomplete="email"
                    inputmode="email"
                  />
                  <.input
                    field={@form[:phone]}
                    type="tel"
                    label="Telefone / WhatsApp"
                    placeholder="(11) 99999-9999"
                    required
                    phx-hook=".PhoneFormatter"
                    phx-debounce="blur"
                  />
                  <.input
                    field={@form[:cpf]}
                    type="text"
                    label="CPF"
                    placeholder="000.000.000-00"
                    required
                    phx-hook=".CpfFormatter"
                    phx-debounce="blur"
                  />
                  <.button
                    type="submit"
                    phx-disable-with="Enviando..."
                    class="btn btn-primary w-full min-h-[48px] text-base mt-2"
                  >
                    Quero uma demonstração gratuita
                  </.button>
                  <p class="text-xs text-center text-base-content/40">
                    Ao enviar, você concorda com nossa <a
                      href="#"
                      class="underline hover:text-base-content transition-colors"
                    >
                      política de privacidade
                    </a>.
                  </p>
                </.form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".PhoneFormatter">
      const onlyNumbers = (value) => value.replace(/\D/g, "")

      const formatPhone = (value) => {
        const digits = onlyNumbers(value).slice(0, 11)
        if (digits.length === 0) return ""
        const ddd = digits.slice(0, 2)
        const rest = digits.slice(2)
        let result = `(${ddd}`
        if (digits.length >= 2) result += ")"
        if (rest.length > 0) result += " "
        if (digits.length <= 10) {
          const part1 = rest.slice(0, 4)
          const part2 = rest.slice(4, 8)
          result += part1
          if (part2) result += `-${part2}`
        } else {
          const part1 = rest.slice(0, 5)
          const part2 = rest.slice(5, 9)
          result += part1
          if (part2) result += `-${part2}`
        }
        return result
      }

      export default {
        mounted() {
          this.el.addEventListener("input", () => {
            this.el.value = formatPhone(this.el.value)
          })
        }
      }
    </script>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".CpfFormatter">
      const onlyNumbers = (value) => value.replace(/\D/g, "")

      const formatCPF = (value) => {
        const digits = onlyNumbers(value).slice(0, 11)
        return digits
          .replace(/^(\d{3})(\d)/, "$1.$2")
          .replace(/^(\d{3})\.(\d{3})(\d)/, "$1.$2.$3")
          .replace(/\.(\d{3})(\d)/, ".$1-$2")
      }

      export default {
        mounted() {
          this.el.addEventListener("input", () => {
            this.el.value = formatCPF(this.el.value)
          })
        }
      }
    </script>
    """
  end
end

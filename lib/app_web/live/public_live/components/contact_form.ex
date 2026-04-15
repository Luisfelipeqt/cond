defmodule AppWeb.PublicLive.Components.ContactForm do
  use AppWeb, :live_component
  alias App.Marketing

  @impl true
  def mount(socket) do
    socket
    |> assign(:form, to_form(Marketing.change_contact(), as: "contact"))
    |> assign(:submitted, false)
    |> ok()
  end

  @impl true
  def handle_event("validate", %{"contact" => params}, socket) do
    params
    |> Marketing.change_contact()
    |> Map.put(:action, :validate)
    |> to_form(as: "contact")
    |> then(&assign(socket, :form, to_form(&1, as: "contact")))
    |> noreply()
  end

  @impl true
  def handle_event("submit", %{"contact" => params}, socket) do
    params =
      params
      |> maybe_update("cpf")
      |> maybe_update("phone")

    case Marketing.create_contact(params) do
      {:ok, _contact} ->
        socket
        |> assign(:submitted, true)
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:form, to_form(changeset, as: "contact"))
        |> noreply()
    end
  end

  defp maybe_update(map, key) do
    if Map.has_key?(map, key) do
      Map.update!(map, key, &only_numbers/1)
    else
      map
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
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
                <div :if={@submitted} class="flex flex-col items-center text-center py-8 gap-4">
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

                <div :if={!@submitted}>
                  <h3 class="text-lg font-bold text-base-content mb-1">Entre em contato</h3>
                  <p class="text-sm text-base-content/50 mb-6">
                    Preencha os dados abaixo e retornaremos em breve.
                  </p>
                  <.form
                    for={@form}
                    id="contact_form"
                    phx-change="validate"
                    phx-submit="submit"
                    phx-target={@myself}
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
                      phx-debounce="blur"
                    />
                    <.input
                      field={@form[:email]}
                      type="email"
                      label="E-mail"
                      placeholder="joao@email.com"
                      required
                      autocomplete="email"
                      inputmode="email"
                      phx-debounce="blur"
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
                      Ao enviar, você concorda com nossa <.link
                        navigate={~p"/privacidade"}
                        class="underline hover:text-base-content transition-colors"
                      >
                      política de privacidade
                    </.link>.
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
    </div>
    """
  end
end

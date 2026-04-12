defmodule AppWeb.HomeLive do
  use AppWeb, :live_view

  alias App.Marketing

  def mount(_params, _session, socket) do
    changeset = Marketing.change_contact()

    {:ok,
     assign(socket,
       form: to_form(changeset, as: "contact"),
       contact_submitted: false
     )}
  end

  def handle_event("validate_contact", %{"contact" => params}, socket) do
    changeset =
      params
      |> Marketing.change_contact()
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: "contact"))}
  end

  def handle_event("submit_contact", %{"contact" => params}, socket) do
    case Marketing.create_contact(params) do
      {:ok, _contact} ->
        {:noreply, assign(socket, contact_submitted: true)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: "contact"))}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

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
        <a href="/" class="text-base font-bold text-base-content tracking-tight focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary rounded">
          síndico.app
        </a>
      </div>

      <%!-- Links centrais — visíveis apenas em telas grandes --%>
      <div class="navbar-center hidden lg:flex">
        <ul class="menu menu-horizontal gap-1 text-sm text-base-content/60">
          <li><a href="#como-funciona" class="hover:text-base-content rounded-lg">Como funciona</a></li>
          <li><a href="#plataforma" class="hover:text-base-content rounded-lg">Plataforma</a></li>
          <li><a href="#para-quem" class="hover:text-base-content rounded-lg">Para quem</a></li>
          <li><a href="#precos" class="hover:text-base-content rounded-lg">Preços</a></li>
        </ul>
      </div>

      <div class="navbar-end gap-2">
        <%!-- Ações desktop --%>
        <.link navigate={~p"/users/log-in"} class="btn btn-ghost btn-sm hidden lg:flex">Entrar</.link>
        <a href="#contato" class="btn btn-primary btn-sm hidden sm:flex">Falar com a equipe</a>
        <Layouts.theme_toggle />

        <%!-- Menu hamburger — visível até lg --%>
        <div class="dropdown dropdown-end lg:hidden">
          <button
            tabindex="0"
            class="btn btn-ghost btn-sm min-h-[44px] min-w-[44px]"
            aria-label="Abrir menu"
            aria-haspopup="true"
          >
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
            </svg>
          </button>
          <ul
            tabindex="0"
            class="menu menu-sm dropdown-content bg-base-100 border border-base-300 rounded-2xl z-50 mt-3 w-60 p-3 shadow-xl"
            role="menu"
          >
            <li role="none"><a href="#como-funciona" class="py-3 text-sm" role="menuitem">Como funciona</a></li>
            <li role="none"><a href="#plataforma" class="py-3 text-sm" role="menuitem">Plataforma</a></li>
            <li role="none"><a href="#para-quem" class="py-3 text-sm" role="menuitem">Para quem</a></li>
            <li role="none"><a href="#precos" class="py-3 text-sm" role="menuitem">Preços</a></li>
            <li class="divider my-1" role="none"></li>
            <li role="none">
              <a href="#contato" class="btn btn-primary btn-sm w-full mt-1" role="menuitem">
                Falar com a equipe
              </a>
            </li>
            <li role="none">
              <.link navigate={~p"/users/log-in"} class="btn btn-ghost btn-sm w-full mt-1" role="menuitem">
                Entrar
              </.link>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <main id="conteudo">

      <%!-- HERO --%>
      <section class="min-h-[85vh] flex items-center px-5 py-16 md:px-6 md:py-24 relative overflow-hidden" aria-labelledby="hero-heading">
        <div class="absolute inset-0 bg-gradient-to-br from-primary/5 via-base-100 to-base-100 pointer-events-none" aria-hidden="true" />
        <div class="max-w-6xl mx-auto w-full relative">
          <div class="max-w-3xl">
            <div class="inline-flex items-center gap-2 bg-primary/10 text-primary rounded-full px-4 py-1.5 mb-7 text-xs font-semibold uppercase tracking-widest">
              <span class="w-1.5 h-1.5 rounded-full bg-primary animate-pulse" aria-hidden="true"></span>
              Acesso antecipado disponível
            </div>
            <h1
              id="hero-heading"
              class="text-4xl sm:text-5xl md:text-6xl lg:text-7xl leading-[1.05] font-extrabold text-base-content tracking-tight mb-5"
            >
              A plataforma que síndicos e administradoras
              <span class="text-primary"> escolhem para escalar.</span>
            </h1>
            <p class="text-lg sm:text-xl text-base-content/60 leading-relaxed mb-9 max-w-2xl">
              Gerencie comunicados, reservas, ocorrências, cotações e documentos em um único sistema. Rastreável, organizado e acessível para toda a sua equipe.
            </p>
            <div class="flex flex-col sm:flex-row gap-3 mb-10">
              <a href="#contato" class="btn btn-primary btn-lg w-full sm:w-auto px-8">
                Falar com nossa equipe
              </a>
              <a href="#como-funciona" class="btn btn-outline btn-lg w-full sm:w-auto">
                Ver como funciona →
              </a>
            </div>
            <ul class="flex flex-col sm:flex-row sm:flex-wrap gap-3 sm:gap-5 text-sm text-base-content/50" aria-label="Benefícios incluídos">
              <li class="flex items-center gap-1.5">
                <svg class="w-4 h-4 text-success flex-shrink-0" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
                Sem cartão de crédito
              </li>
              <li class="flex items-center gap-1.5">
                <svg class="w-4 h-4 text-success flex-shrink-0" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
                100% web, sem instalação
              </li>
              <li class="flex items-center gap-1.5">
                <svg class="w-4 h-4 text-success flex-shrink-0" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
                Suporte em português
              </li>
            </ul>
          </div>
        </div>
      </section>

      <%!-- DOR --%>
      <section class="py-14 px-5 md:py-24 md:px-6 bg-base-200/50" aria-labelledby="dor-heading">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-10 md:mb-14">
            <h2 id="dor-heading" class="text-2xl sm:text-3xl md:text-4xl font-bold text-base-content mb-4">
              Isso parece familiar?
            </h2>
            <p class="text-base-content/60 max-w-xl mx-auto text-sm sm:text-base">
              A maioria dos síndicos e administradoras ainda opera com as mesmas ferramentas de dez anos atrás.
            </p>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="card bg-base-100 border border-base-300">
              <div class="card-body p-6 md:p-7 gap-3">
                <div class="text-3xl" aria-hidden="true">💬</div>
                <h3 class="text-base md:text-lg font-bold text-base-content">"O grupo de WhatsApp tem 300 mensagens por dia."</h3>
                <p class="text-sm text-base-content/60 leading-relaxed">
                  Comunicados se perdem entre fotos e reclamações. Moradores dizem que não foram avisados. Você passa horas reenviando informações.
                </p>
              </div>
            </div>
            <div class="card bg-base-100 border border-base-300">
              <div class="card-body p-6 md:p-7 gap-3">
                <div class="text-3xl" aria-hidden="true">📊</div>
                <h3 class="text-base md:text-lg font-bold text-base-content">"Tenho 8 planilhas diferentes para 8 condomínios."</h3>
                <p class="text-sm text-base-content/60 leading-relaxed">
                  Cada prédio com sua própria lógica, seu próprio arquivo. Qualquer mudança vira um projeto. Prestar contas então, nem se fala.
                </p>
              </div>
            </div>
            <div class="card bg-base-100 border border-base-300">
              <div class="card-body p-6 md:p-7 gap-3">
                <div class="text-3xl" aria-hidden="true">📋</div>
                <h3 class="text-base md:text-lg font-bold text-base-content">"Cotações? Ainda por e-mail e sem comparativo."</h3>
                <p class="text-sm text-base-content/60 leading-relaxed">
                  Pede proposta por e-mail, espera dias, recebe em formatos diferentes, tenta comparar manualmente. O mesmo ciclo todo mês.
                </p>
              </div>
            </div>
          </div>
          <div class="text-center mt-8">
            <p class="text-base-content/60 font-medium text-sm sm:text-base">
              Existe uma forma melhor.
              <a href="#plataforma" class="text-primary font-semibold hover:underline">Veja como →</a>
            </p>
          </div>
        </div>
      </section>

      <%!-- COMO FUNCIONA --%>
      <section class="py-14 px-5 md:py-24 md:px-6" id="como-funciona" aria-labelledby="como-funciona-heading">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-12 md:mb-16">
            <div class="inline-flex items-center gap-2 bg-primary/10 text-primary rounded-full px-4 py-1.5 mb-5 text-xs font-semibold uppercase tracking-widest" aria-hidden="true">
              Como funciona
            </div>
            <h2 id="como-funciona-heading" class="text-2xl sm:text-3xl md:text-4xl font-bold text-base-content mb-4">
              Do cadastro à operação em minutos.
            </h2>
            <p class="text-base-content/60 max-w-lg mx-auto text-sm sm:text-base">
              Sem implantação complexa, sem treinamento de semanas. Você configura, convida sua equipe e começa a operar no mesmo dia.
            </p>
          </div>
          <ol class="grid grid-cols-1 md:grid-cols-3 gap-8 md:gap-6 list-none" aria-label="Passos para começar">
            <li class="flex flex-row md:flex-col items-start md:items-center gap-5 md:gap-4 md:text-center">
              <div class="inline-flex items-center justify-center w-16 h-16 md:w-24 md:h-24 rounded-2xl bg-base-200 border border-base-300 flex-shrink-0" aria-hidden="true">
                <span class="text-3xl md:text-5xl font-black text-primary/20">1</span>
              </div>
              <div>
                <h3 class="text-lg md:text-xl font-bold text-base-content mb-2">Cadastre sua organização</h3>
                <p class="text-sm text-base-content/60 leading-relaxed md:max-w-xs md:mx-auto">
                  Crie sua conta, adicione seus condomínios e convide sua equipe. Tudo pronto em menos de 10 minutos.
                </p>
              </div>
            </li>
            <li class="flex flex-row md:flex-col items-start md:items-center gap-5 md:gap-4 md:text-center">
              <div class="inline-flex items-center justify-center w-16 h-16 md:w-24 md:h-24 rounded-2xl bg-base-200 border border-base-300 flex-shrink-0" aria-hidden="true">
                <span class="text-3xl md:text-5xl font-black text-primary/20">2</span>
              </div>
              <div>
                <h3 class="text-lg md:text-xl font-bold text-base-content mb-2">Configure e personalize</h3>
                <p class="text-sm text-base-content/60 leading-relaxed md:max-w-xs md:mx-auto">
                  Adicione unidades, moradores, áreas comuns e fornecedores. Configure de acordo com a realidade de cada prédio.
                </p>
              </div>
            </li>
            <li class="flex flex-row md:flex-col items-start md:items-center gap-5 md:gap-4 md:text-center">
              <div class="inline-flex items-center justify-center w-16 h-16 md:w-24 md:h-24 rounded-2xl bg-base-200 border border-base-300 flex-shrink-0" aria-hidden="true">
                <span class="text-3xl md:text-5xl font-black text-primary/20">3</span>
              </div>
              <div>
                <h3 class="text-lg md:text-xl font-bold text-base-content mb-2">Opere com eficiência</h3>
                <p class="text-sm text-base-content/60 leading-relaxed md:max-w-xs md:mx-auto">
                  Comunicados, reservas, ocorrências, cotações e documentos — tudo centralizado, rastreável e acessível de qualquer lugar.
                </p>
              </div>
            </li>
          </ol>
        </div>
      </section>

      <%!-- PLATAFORMA --%>
      <section class="py-14 px-5 md:py-24 md:px-6 bg-base-200/50" id="plataforma" aria-labelledby="plataforma-heading">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-10 md:mb-14">
            <div class="inline-flex items-center gap-2 bg-primary/10 text-primary rounded-full px-4 py-1.5 mb-5 text-xs font-semibold uppercase tracking-widest" aria-hidden="true">
              Plataforma completa
            </div>
            <h2 id="plataforma-heading" class="text-2xl sm:text-3xl md:text-4xl font-bold text-base-content mb-4">
              Seis módulos. Uma plataforma integrada.
            </h2>
            <p class="text-base-content/60 max-w-lg mx-auto text-sm sm:text-base">
              Cada módulo foi projetado para resolver um problema real da gestão de condomínios — e todos se comunicam entre si.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <div :for={{title, desc, highlight, icon_path} <- [
              {"Comunicados",
               "Envie avisos com confirmação de leitura por morador. Saiba exatamente quem viu e quando. Chega de \"não fui avisado\".",
               "Confirmação de leitura por unidade",
               "M10.34 15.84c-.688-.06-1.386-.09-2.09-.09H7.5a4.5 4.5 0 110-9h.75c.704 0 1.402-.03 2.09-.09m0 9.18c.253.962.584 1.892.985 2.783.247.55.06 1.21-.463 1.511l-.657.38c-.551.318-1.26.117-1.527-.461a20.845 20.845 0 01-1.44-4.282m3.102.069a18.03 18.03 0 01-.59-4.59c0-1.586.205-3.124.59-4.59m0 9.18a23.848 23.848 0 018.835 2.535M10.34 6.66a23.847 23.847 0 008.835-2.535m0 0A23.74 23.74 0 0018.795 3m.38 1.125a23.91 23.91 0 011.014 5.395m-1.014 8.855c-.118.38-.245.754-.38 1.125m.38-1.125a23.91 23.91 0 001.014-5.395m0-3.46c.495.413.811 1.035.811 1.73 0 .695-.316 1.317-.811 1.73m0-3.46a24.347 24.347 0 010 3.46"},
              {"Reservas de Áreas",
               "Churrasqueira, salão de festas, academia. Moradores reservam online, o sistema bloqueia conflitos automaticamente.",
               "Sem conflito de horário, sem ligação",
               "M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5"},
              {"Ocorrências",
               "Morador registra o chamado, síndico acompanha e fecha. Histórico completo de cada ocorrência, do início ao fim.",
               "Rastreabilidade total por condomínio",
               "M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z"},
              {"Financeiro",
               "Receitas, despesas e saldo do mês por condomínio. Prestação de contas clara, sem planilha e sem retrabalho.",
               "Relatórios por competência e período",
               "M2.25 18.75a60.07 60.07 0 0115.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 013 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 00-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 01-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 003 15h-.75M15 10.5a3 3 0 11-6 0 3 3 0 016 0zm3 0h.008v.008H18V10.5zm-12 0h.008v.008H6V10.5z"},
              {"Cotações",
               "Compartilhe um link com o fornecedor, receba a proposta formatada no sistema e compare lado a lado. Sem e-mail, sem planilha.",
               "Comparativo automático de propostas",
               "M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25zM6.75 12h.008v.008H6.75V12zm0 3h.008v.008H6.75V15zm0 3h.008v.008H6.75V18z"},
              {"Documentos com IA",
               "Atas, relatórios e avisos gerados por inteligência artificial a partir de templates. Em segundos, com precisão.",
               "Templates reutilizáveis por tipo de documento",
               "M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 00-2.456 2.456z"}
            ]} class="card bg-base-100 border border-base-300 hover:border-primary/30 hover:shadow-md transition-all duration-200">
              <div class="card-body gap-4 p-5 md:p-7">
                <div class="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center flex-shrink-0">
                  <svg class="w-5 h-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" d={icon_path} />
                  </svg>
                </div>
                <div>
                  <h3 class="font-bold text-base-content mb-1.5">{title}</h3>
                  <p class="text-sm text-base-content/60 leading-relaxed">{desc}</p>
                </div>
                <div class="flex items-center gap-1.5 text-xs text-primary font-medium">
                  <span class="w-1.5 h-1.5 rounded-full bg-primary flex-shrink-0" aria-hidden="true"></span>
                  {highlight}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- PARA QUEM --%>
      <section class="py-14 px-5 md:py-24 md:px-6" id="para-quem" aria-labelledby="para-quem-heading">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-10 md:mb-14">
            <div class="inline-flex items-center gap-2 bg-primary/10 text-primary rounded-full px-4 py-1.5 mb-5 text-xs font-semibold uppercase tracking-widest" aria-hidden="true">
              Para quem é
            </div>
            <h2 id="para-quem-heading" class="text-2xl sm:text-3xl md:text-4xl font-bold text-base-content mb-4">
              Feito para quem leva gestão a sério.
            </h2>
          </div>
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-5">
            <div class="card bg-base-100 border border-base-300">
              <div class="card-body p-6 md:p-10 gap-5">
                <div>
                  <div class="badge badge-primary badge-outline mb-3">Administradoras de condomínios</div>
                  <h3 class="text-xl md:text-2xl font-bold text-base-content mb-2">Escale sem aumentar o time.</h3>
                  <p class="text-base-content/60 leading-relaxed text-sm md:text-base">
                    Gerencie dezenas de condomínios a partir de um único painel. Padronize processos, elimine retrabalho e entregue mais valor para cada cliente.
                  </p>
                </div>
                <ul class="space-y-2.5" aria-label="Benefícios para administradoras">
                  <li :for={item <- [
                    "Painel unificado para todos os condomínios da carteira",
                    "Templates e processos padronizados entre condomínios",
                    "Cadastro central de fornecedores com histórico de cotações",
                    "Relatórios e prestação de contas automatizados"
                  ]} class="flex items-start gap-3">
                    <div class="w-5 h-5 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5" aria-hidden="true">
                      <svg class="w-3 h-3 text-primary" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                      </svg>
                    </div>
                    <span class="text-sm text-base-content/70">{item}</span>
                  </li>
                </ul>
              </div>
            </div>

            <div class="card bg-base-100 border border-base-300">
              <div class="card-body p-6 md:p-10 gap-5">
                <div>
                  <div class="badge badge-primary badge-outline mb-3">Síndicos profissionais</div>
                  <h3 class="text-xl md:text-2xl font-bold text-base-content mb-2">De 5 a 30 prédios? A gente resolve.</h3>
                  <p class="text-base-content/60 leading-relaxed text-sm md:text-base">
                    Troque os grupos de WhatsApp por comunicados rastreáveis, as planilhas por financeiro estruturado e o caderno por reservas digitais.
                  </p>
                </div>
                <ul class="space-y-2.5" aria-label="Benefícios para síndicos profissionais">
                  <li :for={item <- [
                    "Tudo de cada prédio em um único lugar organizado",
                    "Histórico completo de comunicados e ocorrências",
                    "Moradores com acesso próprio para reservas e chamados",
                    "Cotações fechadas em minutos, não em dias"
                  ]} class="flex items-start gap-3">
                    <div class="w-5 h-5 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5" aria-hidden="true">
                      <svg class="w-3 h-3 text-primary" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                      </svg>
                    </div>
                    <span class="text-sm text-base-content/70">{item}</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- DEPOIMENTOS --%>
      <section class="py-14 px-5 md:py-24 md:px-6 bg-base-200/50" aria-labelledby="depoimentos-heading">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-10 md:mb-14">
            <h2 id="depoimentos-heading" class="text-2xl sm:text-3xl md:text-4xl font-bold text-base-content mb-3">
              Quem já está testando, aprovou.
            </h2>
            <p class="text-base-content/60 max-w-md mx-auto text-sm sm:text-base">
              Feedbacks de síndicos e administradoras que participaram do nosso beta fechado.
            </p>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div :for={{initials, name, role, quote} <- [
              {"MS", "Maria Santos", "Síndica Profissional · São Paulo, SP",
               "Reduzi pelo menos 3 horas por semana só nas comunicações. Agora tudo fica registrado e os moradores não podem mais dizer que não foram avisados."},
              {"CO", "Carlos Oliveira", "Administradora Oliveira Gestão · Rio de Janeiro, RJ",
               "Antes eu tinha 4 grupos de WhatsApp por prédio. Agora tudo fica no sistema e minha equipe consegue acompanhar em tempo real, de qualquer lugar."},
              {"AL", "Ana Lima", "Síndica Profissional · Belo Horizonte, MG",
               "A parte de cotações mudou tudo. Mando o link para o fornecedor e recebo a proposta formatada diretamente no sistema. Simples assim."}
            ]} class="card bg-base-100 border border-base-300">
              <div class="card-body p-6 md:p-8 gap-4">
                <div class="flex gap-0.5" role="img" aria-label="Avaliação: 5 de 5 estrelas">
                  <span :for={_ <- 1..5} class="text-warning" aria-hidden="true">★</span>
                </div>
                <p class="text-sm text-base-content/70 leading-relaxed italic">"{quote}"</p>
                <div class="flex items-center gap-3 mt-auto pt-2">
                  <div class="avatar placeholder" aria-hidden="true">
                    <div class="bg-primary/10 text-primary rounded-full w-10 h-10">
                      <span class="text-sm font-bold">{initials}</span>
                    </div>
                  </div>
                  <div>
                    <p class="text-sm font-semibold text-base-content">{name}</p>
                    <p class="text-xs text-base-content/50">{role}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- PREÇOS --%>
      <section class="py-14 px-5 md:py-24 md:px-6" id="precos" aria-labelledby="precos-heading">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-10 md:mb-14">
            <div class="inline-flex items-center gap-2 bg-primary/10 text-primary rounded-full px-4 py-1.5 mb-5 text-xs font-semibold uppercase tracking-widest" aria-hidden="true">
              Preços
            </div>
            <h2 id="precos-heading" class="text-2xl sm:text-3xl md:text-4xl font-bold text-base-content mb-4">
              Por unidade, não por condomínio.
            </h2>
            <p class="text-base-content/60 max-w-xl mx-auto text-sm sm:text-base">
              Um prédio de 200 apartamentos gera muito mais trabalho que um de 20. O preço é proporcional — justo para quem começa, escalável para quem cresce.
            </p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-5">
            <div class="card bg-base-100 border border-base-300">
              <div class="card-body p-5 md:p-7 gap-3">
                <p class="text-xs font-semibold text-base-content/40 uppercase tracking-wider">Básico</p>
                <div>
                  <p class="text-2xl md:text-3xl font-extrabold text-base-content">
                    R$ 8<span class="text-sm font-normal text-base-content/40">/unid</span>
                  </p>
                  <p class="text-xs text-base-content/40 mt-1">até 50 unidades</p>
                </div>
                <div class="border-t border-base-300 pt-3">
                  <p class="text-xs text-base-content/40">Ex: 50 unidades</p>
                  <p class="text-sm font-bold text-base-content">R$ 400/mês</p>
                </div>
              </div>
            </div>
            <div class="card bg-base-100 border border-base-300">
              <div class="card-body p-5 md:p-7 gap-3">
                <p class="text-xs font-semibold text-base-content/40 uppercase tracking-wider">Crescimento</p>
                <div>
                  <p class="text-2xl md:text-3xl font-extrabold text-base-content">
                    R$ 6<span class="text-sm font-normal text-base-content/40">/unid</span>
                  </p>
                  <p class="text-xs text-base-content/40 mt-1">51 – 150 unidades</p>
                </div>
                <div class="border-t border-base-300 pt-3">
                  <p class="text-xs text-base-content/40">Ex: 150 unidades</p>
                  <p class="text-sm font-bold text-base-content">R$ 900/mês</p>
                </div>
              </div>
            </div>
            <div class="card bg-primary text-primary-content relative shadow-lg shadow-primary/20 mt-4 sm:mt-4 lg:mt-0">
              <div class="absolute -top-4 inset-x-0 flex justify-center" aria-label="Plano mais popular">
                <span class="badge badge-sm bg-primary-content text-primary font-bold border-0 px-3">Mais popular</span>
              </div>
              <div class="card-body p-5 md:p-7 gap-3">
                <p class="text-xs font-semibold text-primary-content/60 uppercase tracking-wider">Pro</p>
                <div>
                  <p class="text-2xl md:text-3xl font-extrabold">
                    R$ 4,50<span class="text-sm font-normal text-primary-content/60">/unid</span>
                  </p>
                  <p class="text-xs text-primary-content/60 mt-1">151 – 500 unidades</p>
                </div>
                <div class="border-t border-primary-content/20 pt-3">
                  <p class="text-xs text-primary-content/60">Ex: 400 unidades</p>
                  <p class="text-sm font-bold">R$ 1.800/mês</p>
                </div>
              </div>
            </div>
            <div class="card bg-neutral text-neutral-content border border-neutral">
              <div class="card-body p-5 md:p-7 gap-3">
                <p class="text-xs font-semibold text-neutral-content/50 uppercase tracking-wider">Enterprise</p>
                <div>
                  <p class="text-2xl md:text-3xl font-extrabold">Sob consulta</p>
                  <p class="text-xs text-neutral-content/50 mt-1">500+ unidades</p>
                </div>
                <div class="border-t border-neutral-content/10 pt-3">
                  <p class="text-xs text-neutral-content/50">Administradoras</p>
                  <p class="text-sm font-bold">Fale conosco</p>
                </div>
              </div>
            </div>
          </div>

          <div class="card bg-base-100 border border-primary/20">
            <div class="card-body p-5 md:p-7 flex-col md:flex-row items-start md:items-center justify-between gap-4">
              <div>
                <p class="text-sm font-bold text-base-content">
                  <span aria-hidden="true">💡</span> Exemplo: síndico com 15 condomínios de 80 unidades cada
                </p>
                <p class="text-xs text-base-content/50 mt-1">Plano Crescimento · 1.200 unidades no total</p>
              </div>
              <div class="shrink-0">
                <p class="text-2xl md:text-3xl font-extrabold text-base-content">
                  R$ 7.200<span class="text-sm font-normal text-base-content/40">/mês</span>
                </p>
                <p class="text-xs text-base-content/40">de um único contrato</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- FORMULÁRIO DE CONTATO --%>
      <section class="py-14 px-5 md:py-24 md:px-6 bg-base-200/50" id="contato" aria-labelledby="contato-heading">
        <div class="max-w-6xl mx-auto">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-14 items-start">

            <%!-- Copy --%>
            <div class="space-y-7 order-2 lg:order-1">
              <div>
                <div class="inline-flex items-center gap-2 bg-primary/10 text-primary rounded-full px-4 py-1.5 mb-5 text-xs font-semibold uppercase tracking-widest" aria-hidden="true">
                  Fale com a equipe
                </div>
                <h2 id="contato-heading" class="text-2xl sm:text-3xl md:text-4xl font-bold text-base-content mb-3 leading-tight">
                  Pronto para deixar o WhatsApp e a planilha no passado?
                </h2>
                <p class="text-base-content/60 leading-relaxed text-sm sm:text-base">
                  Preencha o formulário e nossa equipe entrará em contato para apresentar a plataforma, tirar dúvidas e montar o plano ideal para a sua operação.
                </p>
              </div>

              <ul class="space-y-4" aria-label="O que esperar após o contato">
                <li :for={{icon_path, title, desc} <- [
                  {"M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z",
                   "Retorno em até 24 horas",
                   "Entraremos em contato por telefone ou email no próximo dia útil."},
                  {"M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
                   "Demo personalizada e gratuita",
                   "Mostramos a plataforma com exemplos da sua realidade operacional."},
                  {"M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z",
                   "Seus dados protegidos",
                   "Não compartilhamos seus dados com terceiros. Nunca."}
                ]} class="flex items-start gap-4">
                  <div class="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center flex-shrink-0" aria-hidden="true">
                    <svg class="w-5 h-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
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
                  <div class="w-16 h-16 rounded-full bg-success/10 flex items-center justify-center" aria-hidden="true">
                    <svg class="w-8 h-8 text-success" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                  <h3 class="text-xl font-bold text-base-content">Recebemos o seu contato!</h3>
                  <p class="text-sm text-base-content/60 max-w-xs">
                    Nossa equipe entrará em contato em até 24 horas. Fique de olho no seu e-mail e telefone.
                  </p>
                </div>

                <div :if={!@contact_submitted}>
                  <h3 class="text-lg font-bold text-base-content mb-1">Entre em contato</h3>
                  <p class="text-sm text-base-content/50 mb-6">Preencha os dados abaixo e retornaremos em breve.</p>

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
                      autocomplete="tel"
                      inputmode="tel"
                    />
                    <.input
                      field={@form[:cpf]}
                      type="text"
                      label="CPF"
                      placeholder="000.000.000-00"
                      required
                      autocomplete="off"
                      inputmode="numeric"
                    />
                    <.button
                      type="submit"
                      phx-disable-with="Enviando..."
                      class="btn btn-primary w-full min-h-[48px] text-base mt-2"
                    >
                      Quero uma demonstração gratuita
                    </.button>
                    <p class="text-xs text-center text-base-content/40">
                      Ao enviar, você concorda com nossa
                      <a href="#" class="underline hover:text-base-content transition-colors">política de privacidade</a>.
                    </p>
                  </.form>
                </div>

              </div>
            </div>

          </div>
        </div>
      </section>

      <%!-- FOOTER --%>
      <footer class="bg-base-200 border-t border-base-300 py-12 px-5 md:px-6">
        <div class="max-w-6xl mx-auto">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-8 mb-10">
            <div class="col-span-2 space-y-3">
              <span class="text-lg font-bold text-base-content">síndico.app</span>
              <p class="text-sm text-base-content/50 max-w-xs leading-relaxed">
                Plataforma de gestão de condomínios para administradoras e síndicos profissionais brasileiros.
              </p>
              <p class="text-xs text-base-content/40">Feito com ♥ no Brasil</p>
            </div>
            <div class="space-y-3">
              <p class="text-xs font-semibold text-base-content/40 uppercase tracking-widest">Produto</p>
              <ul class="space-y-2 text-sm text-base-content/60">
                <li><a href="#plataforma" class="hover:text-base-content transition-colors min-h-[44px] flex items-center">Plataforma</a></li>
                <li><a href="#precos" class="hover:text-base-content transition-colors min-h-[44px] flex items-center">Preços</a></li>
                <li><a href="#como-funciona" class="hover:text-base-content transition-colors min-h-[44px] flex items-center">Como funciona</a></li>
              </ul>
            </div>
            <div class="space-y-3">
              <p class="text-xs font-semibold text-base-content/40 uppercase tracking-widest">Empresa</p>
              <ul class="space-y-2 text-sm text-base-content/60">
                <li><a href="#contato" class="hover:text-base-content transition-colors min-h-[44px] flex items-center">Fale conosco</a></li>
                <li><a href="#" class="hover:text-base-content transition-colors min-h-[44px] flex items-center">Privacidade</a></li>
                <li><a href="#" class="hover:text-base-content transition-colors min-h-[44px] flex items-center">Termos de uso</a></li>
                <li><.link href={~p"/users/log-in"} class="hover:text-base-content transition-colors min-h-[44px] flex items-center">Entrar</.link></li>
              </ul>
            </div>
          </div>
          <div class="border-t border-base-300 pt-8 flex flex-col sm:flex-row items-center justify-between gap-3">
            <p class="text-xs text-base-content/40">© {Date.utc_today().year} síndico.app — Todos os direitos reservados.</p>
            <p class="text-xs text-base-content/40">CNPJ em processo de abertura</p>
          </div>
        </div>
      </footer>

    </main>
    """
  end
end

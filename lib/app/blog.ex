defmodule App.Blog do
  @moduledoc "Static blog posts for the síndico.app marketing site."

  defstruct [
    :slug,
    :title,
    :excerpt,
    :body,
    :author,
    :published_at,
    :read_time,
    :tag,
    :cover_color
  ]

  defp posts do
    [
      %__MODULE__{
        slug: "whatsapp-nao-e-gestao-de-condominio",
        title: "Por que o WhatsApp está sabotando sua gestão de condomínio",
        excerpt:
          "O WhatsApp resolve comunicação entre amigos. Mas quando você tenta gerir um condomínio por lá, o custo invisível cresce a cada semana — e a maioria dos síndicos só percebe tarde demais.",
        tag: "Gestão",
        cover_color: "bg-warning/10 text-warning",
        author: "Equipe síndico.app",
        published_at: ~D[2026-04-02],
        read_time: 4,
        body: [
          {:p,
           "Você abre o grupo do condomínio de manhã e já tem 47 mensagens. Uma reclamação sobre barulho, três moradores perguntando sobre a reunião, alguém reclamando que o elevador está lento, uma foto de uma torneira pingando e um áudio de dois minutos que você vai ouvir mais tarde — talvez."},
          {:p,
           "Isso é a realidade de quem tenta gerir condomínios pelo WhatsApp. E se você reconhece esse cenário, saiba que não está sozinho."},
          {:h2, "O problema não é o WhatsApp — é o uso errado"},
          {:p,
           "O WhatsApp é uma ferramenta de comunicação social. Foi projetado para conversas rápidas e informais entre pessoas que se conhecem. Não foi projetado para registrar ocorrências, rastrear comunicados, organizar reservas ou documentar decisões de assembleia."},
          {:p,
           "Quando você usa o WhatsApp como sistema de gestão, está usando uma ferramenta errada para um trabalho sério. O resultado é sempre o mesmo:"},
          {:ul,
           [
             "Comunicados importantes se perdem no meio de conversas triviais",
             "Não há registro de quem viu o quê e quando",
             "Decisões tomadas em conversa de grupo não têm validade legal",
             "Novos moradores não têm acesso ao histórico",
             "Você passa horas respondendo as mesmas perguntas em diferentes grupos"
           ]},
          {:h2, "O custo real que você não está calculando"},
          {:p,
           "Vamos fazer uma conta simples. Se você gasta 30 minutos por dia respondendo mensagens de WhatsApp sobre gestão — comunicados que se perderam, dúvidas sobre reservas, status de ocorrências — isso são 10 horas por mês. Por condomínio."},
          {:p,
           "Um síndico profissional com 10 condomínios? São 100 horas mensais desperdiçadas em comunicação reativa. Isso é mais de duas semanas de trabalho por mês. Tempo que poderia ser usado para crescer a carteira, melhorar os processos ou simplesmente descansar."},
          {:blockquote,
           "\"Reduzi pelo menos 3 horas por semana só nas comunicações. Agora tudo fica registrado e os moradores não podem mais dizer que não foram avisados.\" — Maria Santos, Síndica Profissional, São Paulo"},
          {:h2, "A alternativa que síndicos profissionais estão adotando"},
          {:p,
           "A mudança não precisa ser traumática. Plataformas como o síndico.app permitem que você envie comunicados com confirmação de leitura por unidade, gerencie reservas de áreas comuns sem conflito, registre e acompanhe ocorrências do início ao fim, e mantenha um histórico completo e rastreável de tudo."},
          {:p,
           "A diferença não é apenas operacional. É uma questão de profissionalismo. Quando um morador questiona se foi avisado sobre uma reunião, você tem a prova. Quando um fornecedor cobra por um serviço contestado, você tem o histórico. Quando um síndico anterior é questionado, você tem a documentação."},
          {:h2, "Por onde começar"},
          {:p,
           "O primeiro passo não é abandonar o WhatsApp do dia para a noite. É entender quais processos estão sendo prejudicados pela falta de uma ferramenta adequada e começar a migrá-los gradualmente."},
          {:p,
           "Se você quer entender como isso funcionaria para a sua operação específica, nossa equipe pode mostrar a plataforma com exemplos da sua realidade. Sem script, sem papo de vendedor — uma conversa técnica sobre como resolver o problema que você tem."}
        ]
      },
      %__MODULE__{
        slug: "como-escalar-sem-aumentar-equipe",
        title: "Como escalar de 5 para 30 condomínios sem aumentar a equipe",
        excerpt:
          "Administradoras que crescem rápido frequentemente cometem o mesmo erro: contratam mais gente em vez de melhorar processos. Veja como as que crescem de forma saudável fazem diferente.",
        tag: "Crescimento",
        cover_color: "bg-success/10 text-success",
        author: "Equipe síndico.app",
        published_at: ~D[2026-04-07],
        read_time: 6,
        body: [
          {:p,
           "Quando uma administradora passa de 5 para 15 condomínios na carteira, algo previsível acontece: a carga operacional não cresce de forma linear — ela explode. Cada novo condomínio traz seus próprios moradores, seus próprios fornecedores, suas próprias peculiaridades. E se os processos não estiverem bem definidos, a equipe começa a se afogar."},
          {:p,
           "A resposta mais comum é contratar mais pessoas. A resposta mais inteligente é padronizar e automatizar antes de contratar."},
          {:h2, "O gargalo não é a equipe — são os processos"},
          {:p,
           "Administradoras que escalam bem têm uma coisa em comum: processos documentados e repetíveis. Elas não dependem de uma pessoa específica saber \"como funciona\" cada condomínio. Qualquer membro da equipe consegue acessar o histórico de ocorrências, verificar o status de uma cotação ou enviar um comunicado."},
          {:p,
           "Quando o conhecimento está na cabeça das pessoas em vez de estar no sistema, escalar significa multiplicar o risco. Se a pessoa responsável por um condomínio fica doente, sai de férias ou pede demissão, tudo trava."},
          {:ul,
           [
             "Processos documentados permitem que qualquer pessoa da equipe atenda qualquer condomínio",
             "Templates padronizados eliminam o retrabalho de criação de documentos",
             "Histórico centralizado garante continuidade independente de rotatividade",
             "Relatórios automatizados reduzem horas de consolidação manual"
           ]},
          {:h2, "O modelo de crescimento saudável"},
          {:p,
           "As administradoras que mais crescem em carteira sem explodir a folha de pagamento seguem um padrão consistente: elas investem em sistemas antes de contratar. Para cada R$ 1 gasto em tecnologia de gestão, economizam R$ 3 a R$ 5 em horas de trabalho manual."},
          {:p,
           "A conta é simples. Um analista de condomínios que gerencia 8 carteiras sem sistema adequado pode gerenciar 15 a 20 com as ferramentas certas. Isso é quase dobrar a capacidade sem dobrar o custo."},
          {:blockquote,
           "\"Antes eu tinha 4 grupos de WhatsApp por prédio. Agora tudo fica no sistema e minha equipe consegue acompanhar em tempo real, de qualquer lugar.\" — Carlos Oliveira, Administradora Oliveira Gestão, Rio de Janeiro"},
          {:h2, "O que um sistema de gestão precisa ter para escalar"},
          {:p, "Não é qualquer sistema que resolve o problema de escala. Você precisa de:"},
          {:ul,
           [
             "Painel unificado com visão de todos os condomínios em um só lugar",
             "Templates de comunicados, atas e relatórios reutilizáveis entre condomínios",
             "Módulo de cotações que elimina o processo manual de e-mail e planilha",
             "Histórico de fornecedores compartilhado entre toda a carteira",
             "Relatórios de prestação de contas automatizados por período"
           ]},
          {:h2, "Quando contratar"},
          {:p,
           "Isso não significa que você nunca vai precisar contratar. Mas a decisão de contratar deve vir depois de ter esgotado o potencial de produtividade que bons processos e ferramentas adequadas proporcionam."},
          {:p,
           "A pergunta certa não é \"preciso contratar mais uma pessoa?\" — é \"minha equipe atual tem as ferramentas certas para trabalhar no máximo da capacidade?\""},
          {:p,
           "Se quiser ver como o síndico.app pode ajudar sua administradora a crescer de forma estruturada, nossa equipe pode apresentar a plataforma com exemplos da sua realidade operacional. Sem compromisso."}
        ]
      },
      %__MODULE__{
        slug: "custo-invisivel-da-planilha",
        title: "O custo invisível da planilha: o que você paga sem perceber",
        excerpt:
          "A planilha parece de graça. Mas quando você soma o tempo gasto criando, atualizando e corrigindo dados manuais, o custo real é bem diferente do que aparece na conta.",
        tag: "Financeiro",
        cover_color: "bg-primary/10 text-primary",
        author: "Equipe síndico.app",
        published_at: ~D[2026-04-10],
        read_time: 5,
        body: [
          {:p,
           "\"Não preciso pagar por um sistema — eu uso planilha.\" Essa frase parece razoável. O Excel ou Google Sheets são gratuitos, você já conhece, e funciona razoavelmente bem para um ou dois condomínios. O problema começa quando essa lógica não evolui com o negócio."},
          {:p,
           "A planilha tem um custo que não aparece na fatura. Ele aparece nas horas que somem, nos erros que passam despercebidos e nas decisões tomadas com dados desatualizados."},
          {:h2, "O tempo que a planilha consome"},
          {:p,
           "Para cada condomínio que você gerencia em planilha, existe uma rotina invisível de manutenção: atualizar lançamentos, criar relatórios mensais, consolidar dados de múltiplas abas, corrigir fórmulas quebradas, exportar para PDF para enviar ao conselho."},
          {:p,
           "Fizemos uma estimativa conservadora com síndicos que usavam planilhas antes de migrar para um sistema. Em média, cada condomínio consumia 4 a 6 horas mensais só em atividades de manutenção de planilha. Um profissional com 10 condomínios está gastando até 60 horas por mês nisso."},
          {:ul,
           [
             "Lançamento manual de receitas e despesas: ~2h/mês por condomínio",
             "Geração de relatório de prestação de contas: ~1,5h/mês",
             "Consolidação e envio ao conselho: ~1h/mês",
             "Correções e auditorias quando algo não fecha: ~1h/mês"
           ]},
          {:h2, "O risco do erro humano"},
          {:p,
           "Planilhas são frágeis. Uma fórmula editada por acidente, uma linha deletada sem querer, um valor copiado para a coluna errada — e você tem um relatório errado que vai para o conselho. Quando alguém percebe, o dano já está feito: tempo perdido para investigar, credibilidade questionada, reunião de emergência convocada."},
          {:p,
           "Sistemas de gestão têm validação de dados, histórico de alterações e impossibilidade de deletar registros sem rastro. Isso não é burocracia — é proteção."},
          {:blockquote,
           "\"A parte de cotações mudou tudo. Mando o link para o fornecedor e recebo a proposta formatada diretamente no sistema. Simples assim.\" — Ana Lima, Síndica Profissional, Belo Horizonte"},
          {:h2, "O custo da falta de rastreabilidade"},
          {:p,
           "Uma planilha não sabe quem fez o quê e quando. Se um lançamento suspeito aparece meses depois, impossível saber quem o inseriu, qual era o contexto ou se foi um erro. Essa falta de rastreabilidade é problemática em qualquer situação, mas em condomínios — onde há obrigação de prestação de contas — pode virar um problema legal."},
          {:h2, "Quando faz sentido mudar"},
          {:p,
           "Se você gerencia mais de 3 condomínios, o custo da planilha já provavelmente supera o custo de um sistema. Se você tem funcionários que precisam acessar os dados, o problema se multiplica — agora você precisa gerenciar permissões, sincronizar versões e torcer para ninguém sobrescrever o arquivo do outro."},
          {:p,
           "A transição não precisa ser imediata nem traumática. Você pode começar pelo módulo financeiro, migrar os dados históricos gradualmente e manter a planilha em paralelo até sentir confiança no novo sistema."},
          {:p,
           "Se quiser entender como a migração funcionaria para o seu caso específico — quantos condomínios, qual o volume de lançamentos, quais relatórios você emite — nossa equipe pode mostrar isso em detalhe. Sem compromisso e sem script de venda."}
        ]
      }
    ]
  end

  def list_posts, do: posts()

  def get_post(slug) do
    case Enum.find(posts(), &(&1.slug == slug)) do
      nil -> {:error, :not_found}
      post -> {:ok, post}
    end
  end

  def format_date(%Date{} = date) do
    months = ~w(jan fev mar abr mai jun jul ago set out nov dez)
    day = date.day
    month = Enum.at(months, date.month - 1)
    year = date.year
    "#{day} #{month}. #{year}"
  end
end

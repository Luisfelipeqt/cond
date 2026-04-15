# Arquitetura

## O que é isso?

Um SaaS multi-tenant para gestão de condomínios. Organizações (administradoras de imóveis ou condomínios autogeridos) assinam a plataforma e gerenciam um ou mais condomínios em uma única conta.

Funcionalidades principais:

- **Gestão de condomínio e unidades** — edifícios, unidades, moradores e membros do conselho
- **Comunicação** — comunicados com confirmação de leitura, registro de ocorrências
- **Reserva de áreas comuns** — moradores reservam espaços com validação de conflitos de horário
- **Geração de documentos** — geração assistida por IA de atas, relatórios financeiros, propostas de orçamento e avisos a partir de templates
- **Gestão de cotações** — solicitar cotações a fornecedores, coletar respostas via links públicos tokenizados, comparar propostas

---

## Stack tecnológica

| Camada | Tecnologia |
|---|---|
| Linguagem | Elixir |
| Framework web | Phoenix LiveView |
| Banco de dados | PostgreSQL |
| ORM | Ecto |
| Autenticação | Magic link + senha (`phx.gen.auth`) |
| E-mail | Swoosh |
| Chaves primárias | UUIDv7 (gerado automaticamente via `App.Schema`) |

---

## Modelo de multi-tenancy

O tenant de nível mais alto é a **Organization**. Ela tem um `type` (condomínio autogerido ou administradora profissional) e um `plan` (basic / professional / enterprise).

```
Organization
└── Condominium (um ou mais por org)
    ├── Unit
    │   └── Member (usuário vinculado a uma unidade com um papel)
    └── Member (usuário vinculado diretamente ao condomínio, ex: conselheiros)
```

Os usuários são globais (schema `identity`) e ganham acesso aos condomínios pela tabela de junção `condo_members`. Um usuário pode ser membro de múltiplos condomínios com papéis diferentes.

**Papéis:** `owner`, `resident`, `board_member`, `manager`

---

## Schemas do banco (namespaces PostgreSQL)

O banco é dividido em cinco schemas PostgreSQL para isolamento de domínio:

```
identity      — usuários e tokens de autenticação (gerenciado pelo phx.gen.auth)
condo         — organizações, condomínios, unidades, membros, áreas comuns, reservas
communication — comunicados, leituras de comunicados, ocorrências
documents     — templates de documentos, documentos gerados, arquivos, jobs de IA
quotation     — fornecedores, solicitações de cotação, itens, respostas, itens de resposta
```

### identity

| Tabela | Finalidade |
|---|---|
| `users` | Contas de usuário (e-mail + senha opcional, confirmed_at) |
| `users_tokens` | Tokens de sessão, magic link e troca de e-mail |

### condo

| Tabela | Finalidade |
|---|---|
| `organizations` | Tenant de nível mais alto |
| `condominiums` | Edifício gerenciado por uma organização |
| `units` | Apartamentos / casas / unidades comerciais dentro de um condomínio |
| `condo_members` | Junção M:N entre usuários e condomínios (papel + unidade opcional) |
| `common_areas` | Espaços compartilhados (piscina, academia, etc.) com regras de disponibilidade |
| `bookings` | Reservas de áreas comuns feitas por usuários |

### communication

| Tabela | Finalidade |
|---|---|
| `announcements` | Avisos oficiais publicados por gestores/conselho para o condomínio |
| `announcement_readings` | Rastreia quais usuários leram cada comunicado |
| `incidents` | Ocorrências relatadas por moradores (barulho, vazamento, segurança, etc.) |

### documents

| Tabela | Finalidade |
|---|---|
| `document_templates` | Templates reutilizáveis com `fields_schema` (JSON) que define os campos do formulário |
| `generated_documents` | Instâncias de documentos criadas a partir de um template, vinculadas a um condomínio |
| `document_files` | Arquivos gerados (PDF, DOCX, PPTX) armazenados em object storage |
| `ai_jobs` | Log de auditoria das chamadas ao LLM — prompt, resposta, tokens usados, status |

### quotation

| Tabela | Finalidade |
|---|---|
| `suppliers` | Cadastro de fornecedores por organização (CNPJ, e-mail, categoria) |
| `quote_requests` | Solicitação de proposta enviada a um ou mais fornecedores |
| `quote_items` | Itens de linha dentro de uma solicitação (descrição, unidade, quantidade) |
| `quote_responses` | Resposta de um fornecedor (acessada via link público tokenizado) |
| `quote_response_items` | Preços por linha enviados pelo fornecedor |

---

## Módulos de domínio

Cada schema PostgreSQL mapeia para um namespace Elixir em `App.*`:

```
App.Accounts          — cadastro, autenticação e sessões de usuário (encapsula identity.*)
App.Condo.*           — Organization, Condo, Unit, Member, CommonArea, Booking
App.Communication.*   — Announcement, AnnouncementReading, Incident
App.Documents.*       — DocumentTemplate, GeneratedDocument, DocumentFile, AiJob
App.Quotation.*       — Supplier, QuoteRequest, QuoteItem, QuoteResponse, QuoteResponseItem
```

Todos os schemas usam `App.Schema` como base, que configura:
- `@primary_key {:id, UUIDv7, autogenerate: true}`
- `@foreign_key_type UUIDv7`

---

## Fluxo de geração de documentos

```
Gestor preenche formulário (baseado no template.fields_schema)
        │
        ▼
GeneratedDocument criado (status: pending)
        │
        ▼
AiJob criado — prompt construído a partir de input_data + template
        │
        ▼
LLM gera o conteúdo (status: running → completed)
        │
        ▼
DocumentFile criado — renderizado para PDF/DOCX/PPTX e armazenado
```

Para documentos de comparação de cotações, o `input_data` contém um `quote_request_id` e a IA resume e compara as respostas dos fornecedores.

---

## Fluxo de cotação

```
Gestor cria QuoteRequest + QuoteItems
        │
        ▼
QuoteResponse criado por fornecedor (cadastrado ou e-mail avulso)
Cada resposta recebe um access_token único + expires_at
        │
        ▼
Fornecedor preenche os preços via URL pública tokenizada (sem login)
QuoteResponseItems armazenados por item de linha
        │
        ▼
Gestor encerra a solicitação → IA gera documento comparativo
QuoteRequest.document_id apontado para o GeneratedDocument resultante
```

---

## Autenticação

Usa `phx.gen.auth` com dois fluxos:

- **Magic link** — usuário se cadastra só com e-mail e recebe um link de acesso único
- **Senha** — opcional, o usuário pode definir uma senha nas configurações

As sessões são rastreadas em `identity.users_tokens` com context `"session"`. O plug `fetch_current_scope_for_user` carrega o usuário atual no conn/socket a cada requisição.

---

## Ordem das migrations

As migrations rodam em ordem de timestamp. A sequência é:

```
000001 — cria os schemas PostgreSQL
000002 — cria identity.users + identity.users_tokens   ← deve rodar antes de qualquer FK para users
000004 — organizations
000005 — condominiums
000006 — units
000007 — condo_members
000008 — common_areas
000009 — incidents
000010 — bookings
000011 — announcements
000012 — announcement_readings
000013 — document_templates
000014 — generated_documents
000015 — document_files
000016 — ai_jobs
000017 — suppliers
000018 — quote_requests
000019 — quote_items
000020 — quote_responses
000021 — quote_response_items
```

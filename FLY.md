# Fly.io — Guia de Operações

App: `sindico-app-snowy-flower-1555`  
Banco: `sindico-app-snowy-flower-1555-db`  
URL: https://sindico-app-snowy-flower-1555.fly.dev

---

## Pré-requisito: autenticar no CLI

```bash
flyctl auth login
```

Abre o browser para login. Só precisa fazer uma vez por máquina.

Verificar se está autenticado:

```bash
flyctl auth whoami
```

---

## Deploy de nova versão

Todo push de nova versão é feito pelo comando abaixo. O build acontece remotamente (Depot), não consome recurso local.

```bash
flyctl deploy --app sindico-app-snowy-flower-1555 --remote-only
```

O que acontece automaticamente:
1. Build da imagem Docker no Depot (servidor remoto do Fly)
2. Executa `/app/bin/migrate` — roda as migrações pendentes
3. Rolling deploy — troca as máquinas sem downtime

> O `--remote-only` é obrigatório aqui pois não temos Docker instalado localmente.

### Ver andamento do deploy

```bash
flyctl logs --app sindico-app-snowy-flower-1555
```

### Ver status das máquinas

```bash
flyctl status --app sindico-app-snowy-flower-1555
```

---

## Variáveis de ambiente (secrets)

Os secrets são variáveis de ambiente disponíveis em todas as máquinas. Nunca vão para o código ou git.

### Listar secrets existentes

```bash
flyctl secrets list --app sindico-app-snowy-flower-1555
```

### Adicionar ou atualizar um secret

```bash
flyctl secrets set NOME_DA_VARIAVEL=valor --app sindico-app-snowy-flower-1555
```

Exemplos reais usados no app:

```bash
flyctl secrets set SECRET_KEY_BASE=... --app sindico-app-snowy-flower-1555
flyctl secrets set DATABASE_URL=... --app sindico-app-snowy-flower-1555
flyctl secrets set ECTO_IPV6=true --app sindico-app-snowy-flower-1555
```

> Setar um secret reinicia as máquinas automaticamente para aplicar a mudança.

### Remover um secret

```bash
flyctl secrets unset NOME_DA_VARIAVEL --app sindico-app-snowy-flower-1555
```

---

## Logs

### Logs em tempo real

```bash
flyctl logs --app sindico-app-snowy-flower-1555
```

### Últimas N linhas (sem seguir)

```bash
flyctl logs --app sindico-app-snowy-flower-1555 --no-tail
```

---

## Conectar ao banco via proxy

O banco não tem acesso público. Para conectar localmente (ex: via TablePlus, DBeaver, psql), use o proxy do Fly:

### Abrir túnel na porta local 5433

```bash
flyctl proxy 5433:5432 -a sindico-app-snowy-flower-1555-db
```

Enquanto esse comando estiver rodando, o banco estará acessível em:

```
host:     localhost
port:     5433
database: app_prod
```

As credenciais estão no arquivo `.env` na raiz do projeto (não commitado).

### Conectar via psql direto (sem proxy)

```bash
flyctl postgres connect -a sindico-app-snowy-flower-1555-db --database app_prod
```

Abre um terminal psql interativo diretamente na máquina do banco.

---

## Rodar comandos no container da app (IEx, migrations manuais, etc.)

### Abrir console IEx na app em produção

```bash
flyctl ssh console --app sindico-app-snowy-flower-1555 --pty -C "/app/bin/app remote"
```

Isso abre um IEx conectado à instância em produção. Útil para debug e operações pontuais.

### Rodar migrações manualmente (se necessário)

```bash
flyctl ssh console --app sindico-app-snowy-flower-1555 --pty -C "/app/bin/migrate"
```

---

## Reiniciar máquinas

### Ver IDs das máquinas

```bash
flyctl status --app sindico-app-snowy-flower-1555
```

### Reiniciar uma máquina específica

```bash
flyctl machine restart <MACHINE_ID> --app sindico-app-snowy-flower-1555
```

### Reiniciar todas

```bash
flyctl machine list --app sindico-app-snowy-flower-1555
# depois para cada ID:
flyctl machine restart <MACHINE_ID> --app sindico-app-snowy-flower-1555
```

---

## Banco de dados

### Ver status do cluster Postgres

```bash
flyctl status --app sindico-app-snowy-flower-1555-db
```

### Reiniciar o banco (se entrar em estado de erro)

```bash
flyctl machine list --app sindico-app-snowy-flower-1555-db
flyctl machine restart <MACHINE_ID> --app sindico-app-snowy-flower-1555-db
```

### Criar backup manual

```bash
flyctl postgres backup create -a sindico-app-snowy-flower-1555-db
```

### Listar backups

```bash
flyctl postgres backup list -a sindico-app-snowy-flower-1555-db
```

---

## Escalar a app

### Mudar quantidade de máquinas

```bash
# Subir para 2 máquinas sempre ativas
flyctl scale count 2 --app sindico-app-snowy-flower-1555
```

### Mudar memória/CPU

```bash
flyctl scale vm shared-cpu-1x --memory 512 --app sindico-app-snowy-flower-1555
```

Configuração atual (no `fly.toml`): 1 CPU compartilhada, 1 GB de RAM.

---

## Comportamento de auto-stop

O `fly.toml` está configurado com `auto_stop_machines = 'stop'` e `min_machines_running = 0`. Isso significa:

- Sem tráfego por alguns minutos → a máquina hiberna (para economizar)
- Nova requisição chega → Fly acorda a máquina automaticamente (~2-3 segundos de cold start)

Para manter sempre ativa (produção real):

```toml
# fly.toml
[http_service]
  min_machines_running = 1
  auto_stop_machines = 'off'
```

---

## Certificado HTTPS

Gerenciado automaticamente pelo Fly.io via Let's Encrypt. Para ver o status:

```bash
flyctl certs list --app sindico-app-snowy-flower-1555
```

Para domínio customizado:

```bash
flyctl certs add meudominio.com.br --app sindico-app-snowy-flower-1555
```

Depois apontar o DNS do domínio para o IP retornado pelo comando acima.

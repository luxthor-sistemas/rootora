---
name: stack-backend
description: Padrões para backend próprio em cloud (Node/TypeScript, Java/Spring ou Python) - monólito modular, casos de uso, persistência, multi-tenant, migrations, erros, observabilidade e jobs. Use ao criar ou alterar código de API, serviços, banco ou jobs.
---

Defaults. Se `docs/architecture.md` diz diferente, ele vence (ex.: hexagonal com Spring Modulith).

## Organização (monólito modular)
```
<modulo>/
  domain/        regras puras: entidades, value objects, cálculos (sem framework, banco, rede, relógio direto)
  application/   casos de uso: autorização, transação, orquestração, portas
  adapters/in/   HTTP (controllers, DTOs), consumidores de eventos, jobs
  adapters/out/  persistência, clientes de serviços externos
  api/           o que outros módulos podem usar (fachada, eventos)
```
- Um módulo só usa outro pelo `api/` dele ou por evento; nunca tabela de outro módulo. Um teste de arquitetura (ArchUnit, dependency-cruiser, import-linter) garante as fronteiras.
- Cadastro simples pode ser enxuto (sem domínio separado); regra densa tem domínio separado da entidade de persistência.

## Regras
- Controller fino: autentica, valida DTO (por operação, nunca a entidade), chama o caso de uso, mapeia a resposta.
- Caso de uso declara a permissão e recebe o tenant da sessão; toda consulta filtra por `tenant_id` (índices começando por ele).
- Erros de negócio em formato único (Problem Details, RFC 9457), sem stack trace.
- Transação no caso de uso; integração externa fora da transação do banco (outbox se precisar de garantia).
- Chamadas externas com timeout, retry com backoff só para operações idempotentes, e comportamento definido para falha.
- Relógio e geradores de ID injetados (testáveis).
- Logs estruturados (JSON) com `correlation_id`, `tenant_id`, sem dado pessoal. Métricas e alertas para jobs e integrações.
- Jobs e eventos carregam `tenant_id` e um ator explícito (usuário ou sistema), e são idempotentes.

## Banco e migrations
- Migrations versionadas (Flyway, Prisma Migrate, Drizzle, Alembic). Nome com data (`V202611201530__descricao`) para evitar conflito entre branches.
- **Migration aplicada não se edita.** Mudança incompatível em expand/contract: adiciona → app usa o novo → remove em migration posterior.
- Tabela de negócio: `id` (UUID v7), `tenant_id NOT NULL`, `criado_em`, `atualizado_em`; únicos locais incluem `tenant_id`; dinheiro em `numeric(15,2)` ou centavos inteiros; datas em `timestamptz`.
- Nada de `DELETE` em registro financeiro/regulatório: estorno ou nova versão.

## Infra
- IaC (OpenTofu/Terraform) só com `plan` local; `apply` pela pipeline (o hook bloqueia). Segredos no gerenciador da cloud.
- Homologação sem dados pessoais reais.

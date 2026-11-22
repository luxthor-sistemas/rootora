---
name: arquitetura
description: Define ou revisa docs/architecture.md (stack, organização, multi-tenant, padrões transversais) e cria ADR só quando a decisão passa nos três filtros. Use para definir arquitetura de projeto novo, rever stack, ou registrar uma decisão técnica.
argument-hint: "[\"Título do ADR\"]"
---

## Arquitetura do projeto
- Leia `docs/product-overview.md`, `docs/architecture.md`, manifestos (`package.json`, `app.json`, `firebase.json`, `build.gradle*`, `pyproject.toml`) e a estrutura de pastas antes de perguntar.
- Entreviste em rodadas curtas (até 3 perguntas, sua recomendação primeiro, com trade-off prático): stack e deploy; organização e fronteiras; dados (multi-tenant, transações, migrations/regras); padrões transversais (auth, erros, logs, testes, ambientes).
- **Simples primeiro.** Para um time de uma pessoa: monólito modular ou serviços gerenciados (Firebase, Supabase, Cloud Run) antes de microsserviços; uma linguagem quando der; nada de fila, cache ou Kubernetes sem necessidade medida. Diga o custo mensal aproximado e o custo de manutenção de cada escolha.
- Apresente o resumo e só grave `docs/architecture.md` após o "ok". Atualize o mapa de pastas e a seção "Projeto" do `AGENTS.md` (ou rode `configurar-projeto`).

## ADR
1. **Filtro**, mesmo quando pedido: a decisão é (a) difícil de reverter, (b) surpreendente para quem lê sem contexto e (c) teve trade-off real entre alternativas concretas? Falhou em algum: não crie ADR; registre na spec ("Decisões do esclarecimento") ou no `plano.md`, e diga por quê.
2. Próximo número livre em `docs/adr/` (4 dígitos), arquivo `NNNN-titulo-kebab.md` a partir de `0000-modelo.md`, status "Proposta".
3. Preencha com o que foi discutido; não invente alternativas que ninguém considerou.
4. Se altera um ADR anterior, registre no anterior "Substituída por ADR-NNNN" com data.
5. Acrescente a linha na tabela de ADRs do `docs/architecture.md`. Status vira "Aceita" só com aprovação do responsável.

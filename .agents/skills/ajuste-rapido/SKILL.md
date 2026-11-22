---
name: ajuste-rapido
description: Trilha rápida para bug, ajuste visual, refactor pequeno, atualização de dependência ou melhoria de docs/pendencias.md - sem spec nem plano, mas com teste, check e autorrevisão. Use quando a mudança cabe em até ~1 dia e não cria regra de negócio nova.
argument-hint: "<descrição do ajuste ou do bug>"
---

## Cabe na trilha rápida?
Sim se: até ~1 dia, nenhuma regra de negócio nova ou alterada, nenhuma tela nova. Se a investigação mostrar que muda regra, toca a trilha crítica (`.agents/trilha-critica.txt`) com alteração de comportamento, ou cresce além disso: pare, explique e recomende spec no chat.

## Passos
1. Branch `fix/<nome-curto>` (bug) ou `chore/<nome-curto>` a partir da `main` atualizada. Árvore suja: pare e mostre.
2. Bug: reproduza com um teste que falha pelo motivo do bug antes de corrigir. Investigue a causa (use o `explorador` se a busca for ampla); procure o mesmo padrão em outros lugares.
3. Corrija. Rode `bash scripts/harness/check.sh`.
4. Autorrevisão rápida com a skill `criterios-revisao` (só a lista "O que verificar", sem spec). Se o diff passou de ~300 linhas ou tocou a trilha crítica, acione o `qa` mesmo assim.
5. Commit em Conventional Commits. Se o item veio de `docs/pendencias.md`, remova a linha no mesmo commit.

## Retorno (até 6 linhas)
Causa, correção, teste que prova, check, branch e próximo passo (PR).

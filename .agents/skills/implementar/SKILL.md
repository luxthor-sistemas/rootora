---
name: implementar
description: Implementa fatias do plano.md de uma feature - código, testes, check, atualização do plano e commit. Sem argumento faz a próxima fatia na sessão; com "todas" orquestra as fatias restantes, cada uma num subagente dev com contexto limpo. Use quando o usuário pedir "implementa", "continua", "próxima fatia", "implementa tudo" ou citar uma fatia.
argument-hint: "[NNN-nome] [número da fatia | todas]"
---

Entrada: feature e fatia que o responsável passou. Sem feature, use a da branch atual (`feat/<NNN-nome>`).

## 1. Retomar
- Leia só o **Painel** do `plano.md` e retome do "Próximo passo exato".
- Árvore suja de uma fatia anterior: confira com `git status`/`git diff --stat` o que é, termine-a ou pergunte antes de seguir.

## 2. Modo
- **Uma fatia (padrão):** a própria sessão executa a próxima fatia (ou a indicada) pela seção 3. Ao terminar, recomende contexto limpo (comando na seção "Ferramenta" das regras) antes da próxima.
- **`todas`:** a sessão vira **orquestradora** e não lê spec nem código. Para cada fatia pendente, em ordem e **uma de cada vez** (subagentes em paralelo na mesma árvore disputam o índice do git):
  1. acione o subagente `dev` com "implementar a fatia <n> de `docs/specs/<NNN-nome>`";
  2. ao voltar, confira em 3 comandos: `git status --porcelain` vazio, `git log -1 --oneline` com o commit da fatia, fatia `[x]` no `plano.md`;
  3. guarde só a linha de resumo do retorno.
  Pare e devolva o painel se o `dev` trouxer pergunta de regra, bloqueio, mudança de escopo ou check falhando, ou se a conferência falhar. No fim, siga a seção 4.
  Cada fatia ganha contexto limpo sem você precisar limpar a sessão; a orquestradora gasta ~20 linhas por fatia.
- Sem subagentes disponíveis: faça uma fatia por vez na sessão, limpando o contexto entre elas.
- Fatia com decisão técnica difícil não prevista no plano: consulte o `arquiteto` antes de codar.

## 3. Executar uma fatia
1. Leia a fatia no `plano.md`, a `spec.md` inteira (regras, mensagens, rótulos) e, se há tela, o `prototipo.html` (fluxo, campos, controles; não copie o HTML — reconstrua com os componentes do projeto). Carregue a skill de stack.
2. Para regra de negócio e correção de bug, **teste primeiro**: escreva o teste do CT, veja falhar pelo motivo certo, implemente. Para tela e glue code, teste junto com o código é suficiente.
3. Implemente seguindo `docs/coding-standards.md`, a skill `seguranca` (todo endpoint, consulta, regra de acesso e log) e a skill de stack. Antes de criar utilitário, procure se já existe.
4. Rode `bash scripts/harness/check.sh`. Corrija até ficar verde. Três tentativas sem sucesso: pare, explique o erro e a hipótese.
5. **Autochecagem:** confira a fatia contra a skill `criterios-revisao` como se fosse o QA. Corrija o que achar.
6. Atualize o `plano.md`: fatia `[x]`, painel (feito, falta, próximo passo), decisões tomadas fora do plano em uma linha. CA/CT novo que surgiu: acrescente na spec **e** no plano, e avise no retorno.
7. Commit: `feat(<escopo>): <fatia>` (ou `fix`/`test`), incluindo o `plano.md`.

## 4. Depois
- Ainda há fatias e o modo era uma fatia: devolva o painel.
- Acabaram as fatias: rode `bash scripts/harness/check.sh completo` e recomende `revisar`.

## Retorno (até 12 linhas)
Fatia feita, arquivos principais, testes (CT cobertos), resultado do check, decisões fora do plano, pendências, próximo passo.

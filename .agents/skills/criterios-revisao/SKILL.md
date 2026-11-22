---
name: criterios-revisao
description: Fonte única do que uma revisão cobra e do que bloqueia. Usada pelos subagentes qa e qa-critico, e pela autochecagem de quem implementa antes de concluir uma fatia. Use ao revisar uma mudança ou conferir a própria fatia.
---

# Critérios de revisão

Quem implementa confere a própria fatia com esta lista; o QA usa a mesma lista. Se um bloqueante não estiver coberto aqui nem nas skills citadas, ele é `[SEM REGRA]` (ver "Retorno").

## Severidade

Só **BLOQUEANTE** trava o PR. É bloqueante:
- violar uma regra inegociável do `AGENTS.md`;
- CA da spec não cumprido, CT sem teste, teste que não prova o CT (não confere a "Prova", ou executa a ação por atalho em vez do caminho de produção), regra ou valor da spec alterado sem fonte;
- vulnerabilidade: autenticação, autorização, BOLA/outro tenant, regra do Firebase permissiva, injeção, segredo exposto, dado pessoal em log ou resposta, remoção de checagem de permissão;
- perda ou corrupção de dados (migration destrutiva, escrita não atômica que deixa estado inconsistente);
- quebra de build, de testes ou do CI.

Todo o resto é **IMPORTANTE** ou **SUGESTÃO**: vai para `docs/pendencias.md`, não gera nova rodada e não muda o veredito. Teste da dúvida: "isso pode ir para produção assim?" Se pode, é melhoria.

## O que verificar, nesta ordem

1. **Spec** (leia a `spec.md` inteira, não só os itens da fatia):
   - Cumpre os CA e não contradiz nenhuma regra, mensagem ou rótulo da spec. Faz algo que não foi pedido?
   - Todo CT tem teste com o ID no nome e o teste confere o que a "Prova" pede.
   - Tela: segue fluxo, campos e controles do `prototipo.html` e mostra os estados previstos (carregando, vazio, erro, sem permissão). Divergência visual é IMPORTANTE; estado ou mensagem da spec faltando é BLOQUEANTE.
   - CA/CT acrescentado durante a implementação está na spec e no plano.
2. **Regras inegociáveis** do `AGENTS.md`.
3. **Arquitetura**: `docs/architecture.md`, `docs/coding-standards.md` e a skill de stack. Inclui reuso (não recriou algo que já existe).
4. **Segurança** (skill `seguranca`): autorização no servidor, isolamento por tenant/dono, atribuição em massa, exposição de dados, injeção, segredos, logs, regras do Firebase.
5. **Testes** (skill `testes`): comportamento e bordas cobertos; teste de isolamento para acesso por ID; teste pelo caminho de produção; nenhum teste enfraquecido ou apagado sem motivo.
6. **Comportamento removido**: o diff apaga ou enfraquece validação, permissão, auditoria, tratamento de erro ou teste existente? Sem motivo na spec: IMPORTANTE (BLOQUEANTE se for permissão ou isolamento).
7. **Dados**: migration nova em vez de editar a aplicada; expand/contract; índices; regras do Firebase atualizadas junto com a estrutura.

Não comente estilo que o formatador ou o lint resolvem.

## Revisão completa

- Leia o diff inteiro antes de responder: `git diff <base>...HEAD`.
- **Liste todos os bloqueantes de uma vez.** Uma rodada que esconde bloqueantes obriga outra rodada.
- Para cada CA tocado, siga o caminho de produção de ponta a ponta (tela → API/função → regra → banco) e confira se o efeito acontece de fato, não só se o teste passa.
- **Achado de padrão, não de linha:** ao achar um problema, procure o mesmo padrão no resto do diff e cite todas as ocorrências no mesmo achado, descrevendo a causa.
- Rode `bash scripts/harness/check.sh completo` se ninguém registrou o resultado no commit atual.

## Rodada de confirmação

- **Só bloqueantes.** Para cada bloqueante anterior: `CORRIGIDO` ou `PENDENTE`, com evidência (`arquivo:linha`). Melhorias anteriores não são conferidas.
- Revise como mudança nova só o diff desde o commit da rodada anterior, procurando só bloqueantes.
- **Vermelho primeiro:** para achado corrigido com teste, a seção "Correções" do `revisao.md` diz que o teste falhou na asserção antes da correção. Confira se a falha corresponde ao achado e se o teste, lido, de fato falharia sem a correção. Sem essa evidência, o achado fica `PENDENTE`.
- Com merge da `main` no intervalo, revise só os commits próprios (`git log --first-parent --no-merges -p <commit>..HEAD`).

## Retorno

Primeira linha: **APROVADO** (nenhum bloqueante) ou **BLOQUEADO**.

Depois, um item por achado, do mais grave ao menos grave, numerados (A1, A2...; na confirmação, mantenha os números e continue a partir do último):

`A<n> [BLOQUEANTE|IMPORTANTE|SUGESTÃO] arquivo:linha — problema (causa) — regra (AGENTS, skill, spec) — correção sugerida`

Bloqueante sem regra escrita em lugar nenhum: acrescente `[SEM REGRA]` e proponha a regra e a skill de destino em uma linha.

Na confirmação, antes dos novos: `A<n> CORRIGIDO|PENDENTE — resumo — evidência`.

Sem achados: só o veredito e uma linha sobre o que foi verificado. Máximo de 40 linhas no total.

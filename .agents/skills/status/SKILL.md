---
name: status
description: Gerente de projeto. Mostra onde o projeto está - features do roadmap, fatias feitas e pendentes, bloqueios, revisões e o próximo passo recomendado. Use quando o usuário perguntar "onde estamos", "o que falta", "status" ou ao retomar o trabalho depois de um tempo.
---

Leia, sem abrir código:
- `docs/roadmap.md` (status das features);
- de cada feature em andamento: o **Painel** do `plano.md` e o último veredito do `revisao.md` (use busca pelo título "Painel" e por "APROVADO|BLOQUEADO"; não leia os arquivos inteiros);
- `git branch --list 'feat/*' 'fix/*' 'chore/*'`, `git status --porcelain` e `git log --oneline -5` da branch atual;
- contagem de linhas de `docs/pendencias.md` em cada seção.

Responda em até 15 linhas:
1. Branch atual e se a árvore está limpa.
2. Feature em andamento: fatias feitas/total, bloqueios, último veredito.
3. Outras branches abertas e há quanto tempo sem commit (branch parada há mais de 7 dias é risco).
4. Próximas features do roadmap e se já têm spec.
5. Pendências acumuladas (melhorias e regras para o harness). Mais de 10 melhorias: sugira um `ajuste-rapido` para elas; regras para o harness: sugira incorporá-las.
6. **Próximo passo recomendado** (um só) e por quê.

Inconsistência (roadmap diz concluída mas o plano tem fatia aberta, branch sem plano, plano sem branch): aponte e sugira a correção. Não corrija sem pedir.

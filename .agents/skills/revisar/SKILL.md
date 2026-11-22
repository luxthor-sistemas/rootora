---
name: revisar
description: Revisão independente da feature atual pelo QA (qa ou qa-critico, conforme a trilha), com uma rodada de correção e confirmação. Só bloqueante trava; melhorias vão para docs/pendencias.md. Use antes de abrir PR ou quando o usuário pedir revisão.
argument-hint: "[NNN-nome]"
---

## 0. Preparar
- Mudanças não commitadas: commite antes. A revisão é sempre de um commit.
- Só antes da primeira rodada: integre a `main` (`git fetch origin` e, se `origin/main` não é ancestral de HEAD, `git merge --no-edit origin/main`). Conflito: `git merge --abort` e pergunte ao responsável se você resolve num commit próprio ou se segue sem integrar. Nunca deixe a árvore em merge.
- Trilha: `bash scripts/harness/trilha.sh` (saída `trilha=nenhuma|padrao|critica` e a lista de arquivos). `nenhuma`: informe e pare.
- Spec: `docs/specs/<NNN-nome>/` (do argumento ou do nome da branch). Arquivo da revisão: `docs/specs/<NNN-nome>/revisao.md`.

## 1. Decidir a rodada pelo `revisao.md`
- Não existe → rodada **completa**.
- Último veredito APROVADO no commit atual → já aprovado; informe e pare.
- Último veredito APROVADO num commit anterior com commits depois → rodada de **confirmação** só sobre esses commits.
- Último veredito BLOQUEADO → rodada de **confirmação** dos bloqueantes pendentes e do diff da correção.

## 2. Acionar o QA
- `qa-critico` na trilha crítica, `qa` na padrão. Passe: trilha, lista de arquivos, caminho da spec, commit base (`git merge-base origin/main HEAD`) e, na confirmação, o caminho do `revisao.md` e o commit da rodada anterior. Não cole o diff.
- **Diff grande** (`git diff --shortstat <base>...HEAD` acima de ~1500 linhas, sem contar lockfiles e arquivos gerados) na rodada completa: divida por fatias. Um acionamento do QA por grupo de fatias consecutivas (passe o intervalo de commits e os CA delas) e, no fim, um acionamento curto só para conferir que todo CA da spec foi entregue e que as fatias se encaixam. Um QA com diff enorme lê pela metade e deixa passar bloqueante.
- Sem subagentes: rode a skill `criterios-revisao` numa sessão nova (contexto limpo é o que dá independência à revisão).
- Acrescente ao fim do `revisao.md`: data, tipo de rodada, commit, agente e o retorno na íntegra. Mostre ao responsável o veredito e os bloqueantes sem resumir.

## 3. Correção (uma rodada só)
- Bloqueantes: mande ao subagente `dev` (ou corrija na sessão, se forem 1–2 linhas ou texto) com o caminho do `revisao.md`. Ele segue "Correção de achados" (padrão em todas as ocorrências, vermelho primeiro). Grave o retorno dele na seção "Correções" do `revisao.md` e commite. Rode esta skill de novo (rodada de confirmação), de preferência em contexto limpo.
- Bloqueante ainda PENDENTE após a correção: não tente uma segunda vez. Pergunte ao responsável: "corrigir de outro jeito (diga como)", "rever a spec" ou "abrir o PR assim mesmo (decisão do responsável)". Bloqueante nunca é "aceito" em silêncio.
- **Melhorias** (IMPORTANTE e SUGESTÃO): não corrija agora. Registre cada uma em `docs/pendencias.md` (seção Melhorias) num commit `docs(<escopo>): melhorias pendentes da revisão`.
- Achado marcado `[SEM REGRA]`: acrescente a regra proposta em `docs/pendencias.md` (seção Regras para o harness).

## 4. PR
- Só com APROVADO no commit atual. Se a `main` andou, integre de novo; merge limpo não pede nova rodada, conflito resolvido pede confirmação só sobre ele.
- `bash scripts/harness/check.sh completo` verde.
- Abra o PR (se o `gh` estiver disponível e o responsável quiser) com o modelo `.github/pull_request_template.md`, incluindo "Revisão: <n> rodadas, APROVADO em <commit>". Não faça merge.
- Atualize `docs/roadmap.md` (em revisão) e a spec (concluída, após o merge pelo responsável).

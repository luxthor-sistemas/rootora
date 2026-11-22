# Manual rápido do harness

Da instalação ao uso diário. O processo é o mesmo nas três instalações (só Claude Code, só Codex, os dois); muda a forma de chamar as coisas. As diferenças estão na seção 4.

---

## 1. Preparar a máquina (uma vez)

1. Instale `git`, `jq` e `python3` (3.11 ou mais novo): `sudo apt install git jq python3`.
2. Descompacte o `harness-core.zip` em `~/harness-core` e versione:
   ```bash
   cd ~/harness-core && git init && git add -A && git commit -m "harness-core"
   bash testes/instalacao.sh        # tem de terminar com "instalacao.sh: ok"
   ```
3. Confira as versões das ferramentas que for usar: `claude --version`, `codex --version`. O Codex precisa ser recente para usar `gpt-6.1-terra` e `gpt-6.2-sol`.
4. No chat, crie **um Projeto por produto** (claude.ai ou ChatGPT) e cole nas instruções o bloco de `nucleo/chat/INSTRUCOES-PROJETO.md`.

---

## 2. Instalar num projeto

```bash
python3 ~/harness-core/instalar.py ~/projetos/meu-produto
```

O instalador pergunta:

| Pergunta | O que escolher |
|---|---|
| Repositório novo ou existente? | Ele sugere pela pasta. "Novo" cria a pasta e o git. |
| (existente com configuração) Zerar ou manter? | **Manter** para atualizar ou mesclar com o que já existe. **Zerar** para começar limpo: a configuração atual vai para `.harness-backup/<data-hora>/`. Docs de produto e specs não são tocados. |
| Para qual ferramenta? | Claude Code, Codex ou os dois (ver seção 4). |

Depois mostra o resumo e pede confirmação. Nada é alterado antes disso.

Para atualizar o harness ou trocar de ferramenta, rode o mesmo comando e escolha "manter". As regras que você preencheu e as skills próprias do projeto continuam.

### Projeto novo, do zero
1. **Chat:** peça "visão de produto", "arquitetura" e, se tem tela, "design system". Anexe os arquivos gerados e o modelo de spec ao Projeto do chat.
2. **Terminal:** rode o instalador (repositório novo) e copie os arquivos do chat para `docs/`.
3. Crie a base do código (`npm create vite@latest`, `npx create-expo-app`, `firebase init`...).
4. Na ferramenta, peça **`configurar-projeto`**. Ele preenche o arquivo de regras, escolhe a skill de stack, ajusta a trilha crítica e os protegidos e garante que a verificação rápida roda.
5. `bash scripts/harness/testes/rodar.sh` e o primeiro commit.

### Projeto que já existe
Faça numa branch (`git switch -c chore/harness`). Rode o instalador (repositório existente).
- **Com o harness antigo:** prefira **zerar**. Depois disso, leve do backup para a skill de stack ou para o arquivo de regras o que era específico do projeto.
- **Manter num projeto com harness antigo:** skills antigas com nome de skill do núcleo viram `<nome>-projeto` (aparece **CONFLITO** no relatório). Mescle e apague. Apague também skills e agentes antigos que duplicam o fluxo (ex.: `especificar`, `detalhar-fatia`, `adr`, `backend-dev`): duas skills para a mesma tarefa fazem o agente escolher a errada.
- Peça **`configurar-projeto`**, rode `bash scripts/harness/testes/rodar.sh`, commite e abra o PR.

---

## 3. O processo (igual nas três instalações)

```
chat: spec.md + prototipo.html ─▶ iniciar-feature ─▶ implementar [todas] ─▶ revisar ─▶ PR (o merge é seu)
feature pequena (até 3 CA, sem tela nova) ─▶ iniciar-feature especifica aqui mesmo
bug / ajuste pequeno ─▶ ajuste-rapido
retomar ─▶ status
```

1. **Spec.** Com tela, várias regras ou documento do cliente, especifique no chat e baixe `spec.md` e `prototipo.html`. Feature pequena: descreva direto no passo 2.
2. **`iniciar-feature`** com o caminho da spec (ex.: `~/Downloads/spec.md`), o nome (`004-convites`) ou a descrição da feature pequena. Ele valida a spec, pergunta o que falta, cria a branch `feat/NNN-nome` e gera o plano. Usa o arquiteto (modelo forte) só se a feature for crítica ou grande.
3. **`implementar todas`.** Faz as fatias em sequência, cada uma num subagente com contexto limpo, e para em pergunta ou bloqueio. Para acompanhar de perto, use `implementar` (uma fatia por vez, limpando o contexto entre elas).
4. **`revisar`.** O QA revisa sem ter escrito o código. Se houver bloqueante, uma rodada de correção e confirmação; depois disso, a decisão é sua.
5. Com **APROVADO**, ele abre o PR. **Merge e deploy são seus.**

**Bug ou ajuste:** `ajuste-rapido o botão salvar não desabilita durante o envio`.
**Retomar um projeto já configurado:** abra a ferramenta na pasta e peça **`status`**. Ele mostra onde parou e o próximo comando.

---

## 4. Fluxo por ferramenta

### Só Claude Code
- **Primeira vez:** abra com `claude` na pasta. Confira `/skills` (devem aparecer `implementar`, `revisar`...) e `/agents` (cinco agentes). Peça "mostra o conteúdo do .env": tem de ser bloqueado.
- **Comandos:** `/iniciar-feature ~/Downloads/spec.md` · `/implementar todas` · `/revisar` · `/ajuste-rapido ...` · `/status`.
- **Contexto:** `/clear` entre fatias commitadas e `/compact` no meio de uma fatia longa. A barra de status avisa acima de 100 mil tokens.
- **Modelo da sessão:** Sonnet (`/model sonnet`). Arquiteto e QA crítico rodam em Opus por conta própria.
- **Perguntas** do agente chegam como opções clicáveis.
- **Regras:** `CLAUDE.md`. Edite as seções do projeto; não mexa no bloco entre os marcadores `harness:ferramenta`.

### Só Codex
- **Primeira vez:** abra com `codex` na pasta, **marque o projeto como confiável** (sem isso ele ignora `.codex/`) e revise os hooks com `/hooks`. Peça "mostra o conteúdo do .env": tem de ser bloqueado.
- **Comandos:** `$iniciar-feature ~/Downloads/spec.md` · `$implementar todas` · `$revisar` · `$ajuste-rapido ...` · `$status`. Pedir em linguagem natural também funciona.
- **Contexto:** `/new` entre fatias commitadas e `/compact` no meio de uma fatia longa.
- **Modelo da sessão:** `gpt-6.1-terra` (`/model`). Arquiteto e QA crítico rodam em `gpt-6.2-sol` por conta própria.
- **Perguntas** do agente chegam como opções numeradas: responda com o número.
- **Regras:** `AGENTS.md`. Mesma regra do bloco gerenciado.
- **Atenção:** se a verificação de fim de turno não estiver ativa na sua versão, o agente roda `check.sh` antes de concluir, porque a regra 8 exige.

### Os dois
- Faça a "primeira vez" das duas ferramentas.
- Regras em `AGENTS.md`; o `CLAUDE.md` só importa esse arquivo.
- **Trocar de ferramenta no meio de uma feature:** termine e commite a fatia, abra a outra ferramenta na mesma pasta e peça `status`. O estado está em `plano.md` e `revisao.md`, não na conversa. Útil quando a cota de uma acaba, ou para planejar numa e implementar na outra.
- Não rode as duas ao mesmo tempo na mesma pasta: elas disputariam o git e a árvore de arquivos.

---

## 5. Quando algo trava

| Sintoma | O que fazer |
|---|---|
| "Bloqueado pelo guard do harness" | É intencional (segredo, push na main, deploy, arquivo protegido). Faça você, ou ajuste `.agents/protegidos.txt` se estiver errado. |
| A verificação falha no fim do turno | Ela bloqueia até 3 vezes por sessão e não repete o mesmo erro: depois do primeiro aviso, só lembra. Log em `.harness/ultimo-check.log`. |
| A verificação é lenta | Peça `configurar-projeto`: ele cria um script `check` que roda só os testes ligados aos arquivos alterados. |
| Desligar a verificação por um momento | `HARNESS_SEM_VERIFICAR=1 claude` (ou `codex`). |
| O `check.sh` não roda o que o projeto precisa | Crie `scripts/check.local.sh`; ele substitui a detecção automática. |
| Skill ou agente não aparece | Rode o instalador de novo (manter) e depois `bash scripts/harness/testes/rodar.sh`. |

---

## 6. Manutenção

- **De tempos em tempos:** abra `docs/pendencias.md`. Melhorias acumuladas viram um `ajuste-rapido`; regras para o harness viram mudança numa skill do `~/harness-core`.
- **Mudar o harness** (skill, modelo, script): edite em `~/harness-core/nucleo`, rode `bash testes/instalacao.sh`, commite e reinstale nos projetos (manter). Não edite as skills do núcleo dentro do projeto: a reinstalação sobrescreve. Skill própria do projeto (nome diferente) pode ser editada à vontade.
- **Trocar de modelo:** `~/harness-core/nucleo/.agents/modelos.toml`, depois reinstale. Exceção num projeto: `.agents/modelos.local.toml` e `python3 scripts/harness/gerar_agentes.py`.

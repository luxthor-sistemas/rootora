# Instruções do projeto para agentes

Fonte das regras deste repositório. O que depende da ferramenta (comandos, subagentes, hooks) está na seção "Ferramenta", no fim.

## Projeto

- **Produto:** Rootora é um app Android para reduzir a procrastinação e o uso excessivo do celular com tarefas fatiadas, sessões de foco e bloqueio de apps. Visão em `docs/projeto/spec.md`.
- **Responsável:** Lucas Diogo decide regra de negócio, escopo, merge e deploy.
- **Stack:** React Native CLI, TypeScript, Kotlin no Android e Firebase Auth, Firestore, Analytics e Crashlytics. Detalhes em `docs/projeto/arquitetura.md`. Skills de stack: `stack-react-native` e `stack-firebase`. O app usa React Native CLI, então aplique apenas as orientações da skill compatíveis com essa instalação.
- `src/screens/`, `src/components/`, `src/navigation/` e `src/theme/` — interface e navegação.
- `src/hooks/`, `src/domain/`, `src/services/` e `src/native/` — fluxos, regras de negócio, Firebase e integração nativa. Testes Jest ficam junto ao código.
- `android/` e `ios/` — projetos nativos. Testes Kotlin ficam em `android/app/src/test/`.
- `docs/projeto/`, `docs/adr/`, `docs/specs/` e `docs/legal/` — documentação do produto, decisões, specs de features e textos legais.

## Comandos

- Verificação rápida (o que o hook roda): `bash scripts/harness/check.sh`
- Verificação completa (antes do PR): `bash scripts/harness/check.sh completo`
- Instalar dependências JavaScript: `npm ci` com Node.js 22.11 ou mais recente.
- Rodar local: `npm start` para o Metro e `npm run android` em outro terminal. Use `npm run android:wsl` quando o Metro estiver no WSL2 e o emulador no Windows.
- Testar um arquivo JavaScript/TypeScript: `npm test -- --runTestsByPath src/services/auth.test.ts`.
- Testar Kotlin: `(cd android && ./gradlew :app:testDebugUnitTest)`. O check do harness roda tipos, lint e Jest. Para alterações nativas, rode também o Gradle e valide em aparelho físico quando envolver bloqueio, permissões ou notificações.

O `check.sh` detecta Node, Gradle e Python sozinho e devolve só as falhas (log completo em `.harness/ultimo-check.log`). Se o projeto precisar de outra coisa, crie `scripts/check.local.sh`.

## Fluxo de trabalho

Feature com tela, várias regras ou documentos do cliente: especificação e protótipo nascem no chat (claude.ai ou ChatGPT, com `chat/INSTRUCOES-PROJETO.md`). Feature pequena pode ser especificada aqui pela própria `iniciar-feature`.

| Situação | Trilha | Caminho |
|---|---|---|
| Feature nova ou mudança de regra | padrão ou crítica | `iniciar-feature` → `implementar` (uma fatia, ou `todas`) → `revisar` → PR |
| Projeto novo, ou stack/estrutura mudou | — | `configurar-projeto` |
| Bug, ajuste visual, refactor pequeno, dependência (até ~1 dia, sem regra nova) | rápida | `ajuste-rapido` |
| "Onde estamos? O que falta?" | — | `status` |

- **Trilha crítica** quando a mudança toca algum caminho de `.agents/trilha-critica.txt` (autenticação, permissões, regras do Firebase, pagamento, migrations, infra, CI, harness). Muda só o rigor da revisão, não o fluxo.
- Uma feature = uma branch `feat/<NNN-nome>` = uma pasta `docs/specs/<NNN-nome>/` com `spec.md`, `plano.md`, `prototipo.html` (se tem tela) e `revisao.md`.
- Fatia = 1 commit (ou poucos) na branch, com seus testes. O estado vive no `plano.md`, não no histórico da conversa.

## Autonomia (o que você decide sozinho)

Decida e siga em frente: nomes internos, estrutura de funções, bibliotecas já presentes no projeto, refactors locais necessários à fatia, casos de teste além dos CT da spec. Registre decisões não óbvias em uma linha na seção "Decisões" do `plano.md`.

Pare e pergunte ao responsável só quando:
1. a spec não cobre uma regra de negócio, ou parece errada (nunca invente regra);
2. a mudança aumentaria o escopo da spec;
3. a ação é irreversível ou sai do repositório (deploy, dados reais, push na `main`, apagar dados);
4. precisa de dependência nova com impacto relevante (tamanho, licença, segurança).

Ao perguntar, traga a sua recomendação e o motivo. Uma pergunta por vez.

## Regras inegociáveis

1. Nada de segredo em arquivo versionado, log, teste ou comentário. `.env*` não é lido nem editado (só `.env.example`).
2. Toda regra crítica é garantida no servidor (API, Cloud Function ou regras do Firebase). UI só esconde.
3. Todo acesso a dado por ID confere dono/tenant na consulta (BOLA). Ver skill `seguranca`.
4. Comportamento novo ou alterado vem com teste. Cada CT da spec tem um teste com o ID no nome (`CT-03: ...`).
5. Migration ou regra de dados já aplicada não é editada; crie uma nova.
6. Não altere arquivos listados em `.agents/protegidos.txt` (o hook bloqueia). Se um parecer errado, descreva a divergência.
7. Não faça push na `main`, push forçado, merge de PR nem deploy. O responsável faz.
8. Não declare pronto com `check.sh` falhando. Se não conseguir resolver em 3 tentativas, pare e explique.
9. Mudança de regra, valor ou critério na `spec.md` durante a implementação só com confirmação do responsável, citando "decisão do responsável em AAAA-MM-DD".

## Economia de contexto (sem perder qualidade)

- Use busca (`grep`/`rg`/glob) antes de abrir arquivos; abra só o trecho necessário. Documentos longos: leia a seção, não o arquivo inteiro.
- Não releia um arquivo que você acabou de editar para conferir.
- Saída de teste e build: use `check.sh` (só falhas). Não cole logs inteiros na conversa.
- Subagentes recebem caminhos, não conteúdo colado; devolvem no máximo 15–20 linhas.
- Fatia concluída e commitada: comece a próxima em contexto limpo (comando na seção "Ferramenta"). O `plano.md` guarda o estado.
- Busca ampla ("onde está X?", "quem chama Y?"): delegue ao subagente `explorador`.

## Squad (subagentes)

Definidos uma vez em `.agents/agents/` (modelo e esforço por nível em `.agents/modelos.toml`) e gerados para a ferramenta por `python3 scripts/harness/gerar_agentes.py`. Não edite os arquivos gerados.

| Papel | Subagente / skill | Quando |
|---|---|---|
| Arquiteto sênior | `arquiteto` (modelo forte) | Planejar feature crítica, grande ou com várias camadas; decisão técnica difícil; ADR. Feature pequena a sessão planeja |
| Dev | sessão principal ou `dev` | Uma fatia: a sessão. `implementar todas`: um `dev` por fatia, em sequência, cada um com contexto limpo |
| QA | `qa` (padrão) / `qa-critico` (crítica) | Revisão independente em contexto limpo, sem editar código |
| Explorador | `explorador` (modelo leve) | Busca somente leitura |
| PM | skill `produto` (e o chat) | Visão, escopo, roadmap |
| UX | skill `prototipar` (e o chat) | Protótipo e estados de tela |
| Gerente de projeto | skill `status` + `docs/roadmap.md` | Onde estamos, próximo passo, riscos |

Como acionar um subagente: ver seção "Ferramenta". Se subagentes não estiverem disponíveis, execute a skill correspondente numa sessão nova.

## Skills

Fluxo: `iniciar-feature`, `planejar`, `implementar`, `revisar`, `ajuste-rapido`, `status`, `configurar-projeto`.
Qualidade: `criterios-revisao` (fonte única do que bloqueia), `seguranca`, `testes`.
Produto e design: `produto`, `arquitetura`, `prototipar`.
Stack: `stack-web-react`, `stack-firebase`, `stack-react-native`, `stack-backend`.

## Pronto significa

Critérios (CA) da fatia atendidos, CT com teste passando, `check.sh` verde, `plano.md` atualizado (fatia `[x]` e painel), commit feito. Feature pronta para PR só com `revisao.md` dizendo **APROVADO** no commit atual.

## Commits e PR

Conventional Commits (`feat(escopo): ...`, `fix`, `test`, `docs`, `refactor`, `chore`). PR com o modelo de `.github/pull_request_template.md`.

<!-- harness:ferramenta (gerado pelo instalador; não edite entre os marcadores) -->
## Ferramenta

### Codex

- **Skills:** `.agents/skills/`. Chame com `$nome` (ex.: `$implementar todas`) ou peça em linguagem natural.
- **Subagentes:** `.codex/agents/*.toml` (gerados). Peça para criar (spawn) o agente pelo nome. No máximo 3 ao mesmo tempo e sem subagente criando subagente (`.codex/config.toml`).
- **Contexto:** fatia commitada → `/new`; contexto grande no meio da fatia → `/compact`.
- **Perguntas ao responsável:** opções numeradas em texto, com a sua recomendação primeiro.
- **Modelo da sessão:** `gpt-6.1-terra` para implementar; troque com `/model`. Os subagentes têm o próprio modelo.
- **Hooks** (`.codex/hooks.json`, exigem projeto confiável e revisão em `/hooks`): `guard.sh` antes de shell e `apply_patch`, `verificar.sh` ao fim do turno. Mesmo assim, rode `bash scripts/harness/check.sh` antes de dizer que terminou (regra 8): a verificação de fim de turno pode não estar ativa.
<!-- /harness:ferramenta -->

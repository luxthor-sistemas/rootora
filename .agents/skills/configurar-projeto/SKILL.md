---
name: configurar-projeto
description: Configura o harness para o projeto real - preenche Projeto e Comandos do AGENTS.md, escolhe a skill de stack, ajusta a trilha crítica e os arquivos protegidos às pastas do projeto e confere o check. Idempotente. Use depois de instalar o harness, depois de criar a base do código, ou quando estrutura, scripts ou stack mudarem.
---

Trabalho de inspeção, sem entrevista. Pergunte só o que não dá para descobrir no repositório, tudo de uma vez no fim.

## 1. Ler
`docs/product-overview.md`, `docs/architecture.md`, `README.md`, `.env.example`, manifestos e scripts (`package.json` de cada pacote, `app.json`/`app.config.*`, `eas.json`, `firebase.json`, `firestore.rules`, `build.gradle*`, `pyproject.toml`), workflows de CI e a árvore até 3 níveis (sem `node_modules`, `build`, `dist`, `.git`). Use busca; não abra arquivo grande inteiro.

Faltando `product-overview.md` ou `architecture.md` preenchidos: anote como lacuna (são feitos no chat ou pelas skills `produto` e `arquitetura`) e siga com o que der.

## 2. `AGENTS.md` (só as seções "Projeto" e "Comandos")
- Produto em uma linha, responsável (se não souber, pergunte), stack, **skill de stack** (uma ou mais entre `stack-web-react`, `stack-firebase`, `stack-react-native`, `stack-backend`), mapa de pastas em 3 a 6 linhas.
- Comandos reais encontrados: rodar local, testes de um arquivo. Nunca invente um comando; se não existe ainda, deixe `[PREENCHER]` e diga no retorno que esta skill deve rodar de novo depois.
- Mantenha o arquivo abaixo de ~130 linhas e não duplique regra que já está numa skill.
- Não altere o bloco entre os marcadores `harness:ferramenta`: o instalador o reescreve a cada atualização.

## 3. Verificação rápida
- `bash scripts/harness/check.sh` precisa rodar algo útil e terminar em poucos minutos. Se não roda nada, ou demora demais, proponha (e, com ok, crie) um script `"check"` no `package.json` que use os arquivos alterados: `vitest related --run $HARNESS_ARQUIVOS` ou `jest --findRelatedTests $HARNESS_ARQUIVOS`, mais typecheck e lint.
- Projeto que precisa de emulador, ordem entre pacotes ou outra linguagem: crie `scripts/check.local.sh` mínimo.

## 4. `.agents/trilha-critica.txt`
Acrescente (sem apagar os padrões genéricos) regex das pastas **reais** deste projeto que tocam: autenticação e sessão, permissões e papéis, regras do Firebase, pagamento e cobrança, dados pessoais, migrations, infraestrutura, deploy e CI. Confira com `bash scripts/harness/trilha.sh` numa mudança simulada ou com `grep -E -f` sobre `git ls-files`.

## 5. `.agents/protegidos.txt`
Proponha apenas o que de fato não deve ser editado por agente: testes de referência com valor de fonte externa, migrations já aplicadas em produção, arquivos gerados. Na dúvida, não proteja: arquivo protegido demais vira atrito.

## 6. Conferir e retornar (até 12 linhas)
- `bash scripts/harness/testes/rodar.sh` verde.
- O que foi preenchido, os padrões acrescentados à trilha crítica, o que foi protegido, lacunas, perguntas e se a skill precisa rodar de novo (ex.: depois da base do código).

---
name: iniciar-feature
description: Começa uma feature - recebe a spec vinda do chat (de qualquer pasta) ou especifica aqui uma feature pequena, valida, resolve lacunas com o responsável, cria a branch feat/<NNN-nome> e gera o plano.md. Use quando o usuário disser "inicia a feature X", "importa a spec", "nova feature" ou apontar um arquivo de spec.
argument-hint: "<NNN-nome | caminho da spec.md | descrição curta da feature>"
---

Entrada: o que o responsável passou ao chamar a skill.

## 1. Árvore e branch base
- `git status --porcelain`: mudança não commitada, pare e mostre.
- `git switch main && git pull --ff-only` (se houver remoto).

## 2. Obter a spec
- **Veio do chat:** aceite o caminho em qualquer pasta (ex.: `~/Downloads/spec.md`). Procure `prototipo.html` ao lado. Sem número: próximo livre em `docs/specs/`, conferido com `docs/roadmap.md`. Mova para `docs/specs/<NNN-nome>/`.
- **Já está em `docs/specs/<NNN-nome>/`:** use.
- **Não há spec e a feature é pequena** (até 3 CA, sem tela nova, sem trilha crítica): especifique aqui. Entrevista curta, uma pergunta por vez com a sua recomendação, e grave no modelo `docs/specs/_modelo/spec.md`. Fonte das regras: "decisão do responsável em <data de hoje>".
- **Não há spec e a feature é maior:** pare e recomende especificar no chat (`chat/INSTRUCOES-PROJETO.md`). Lá ele tem os documentos do cliente e o protótipo.

## 3. Validar (barato, antes de gastar com planejamento)
- `python3 scripts/harness/verificar_spec.py docs/specs/<NNN-nome>`.
- Leia a spec inteira uma vez: regra ambígua, mensagem de erro sem texto, tela sem estados, conflito com o "Não inclui" do `docs/product-overview.md` ou com `docs/glossario.md`.
- Trilha: se a spec diz "padrão" mas toca algo de `.agents/trilha-critica.txt` (auth, permissões, regras do Firebase, pagamento, dados pessoais), corrija para "crítica" e avise.
- **Forma** (ID faltando, formatação, CT sem nome): corrija você.
- **Lacuna de regra:** não mande de volta para o chat. Pergunte ao responsável aqui, todas as lacunas numa rodada, cada uma com a sua recomendação. Grave as respostas na spec (regra com fonte "decisão do responsável em <data>" e linha na seção "Decisões do esclarecimento"). Volte ao chat só se a resposta mudar tela ou fluxo de forma que exija novo protótipo.

## 4. Branch e registro
- `git switch -c feat/<NNN-nome>` (ou troque para ela, se já existe).
- Termos novos que não estão em `docs/glossario.md`: acrescente. Roadmap: "em implementação". Spec: "aprovada".

## 5. Planejar, com o custo certo
- **Subagente `arquiteto`** (modelo forte) quando: trilha crítica, **ou** mais de 4 CA, **ou** mudança em mais de uma camada (dados + API + tela), **ou** schema/migration/regra do Firebase. Passe só: "planejar `docs/specs/<NNN-nome>`".
- **Na própria sessão**, seguindo a skill `planejar`, para o resto (feature pequena, uma camada). Planejar com o modelo forte uma feature de 2 CA desperdiça tokens sem ganho de qualidade.
- Sem subagentes disponíveis: skill `planejar` na sessão.

## 6. Commit e retorno
Commit `docs(<NNN-nome>): spec e plano`. Retorno em até 8 linhas: branch, trilha, quem planejou, fatias (número, tag, título), riscos e o próximo passo: `implementar` (uma fatia) ou `implementar todas`.

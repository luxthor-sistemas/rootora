---
name: planejar
description: Gera ou atualiza o plano.md de uma feature a partir da spec aprovada e do código atual - fatias verticais, contratos públicos, teste de cada CT e riscos. Usada pelo subagente arquiteto; também para replanejar uma fatia quando o código mudou.
argument-hint: "docs/specs/<NNN-nome> [número da fatia para replanejar só ela]"
---

Objetivo: um plano que um modelo médio execute sem decidir projeto, mas sem ditar detalhe interno. Contrato público é decisão do plano; implementação interna é decisão de quem codifica.

## 1. Ler (só o necessário)
- `spec.md` inteira. Regra faltando ou contraditória: pare e devolva a pergunta. Não altere regra.
- `docs/architecture.md` (seções relevantes), ADRs citados, a skill de stack do projeto.
- Código: use busca para achar o que já existe (módulos, serviços, componentes, coleções/tabelas, migrations, utilitários, padrões de teste). Reuse antes de criar. Todo caminho citado no plano existe (conferido) ou está marcado "criar".
- Se `plano.md` já existe e só uma fatia foi pedida: reescreva só ela.

## 2. Fatiar
- Fatias verticais de 0,5 a 2 dias, cada uma demonstrável pelos próprios testes. Os testes ficam **dentro** da fatia, não numa fatia final: bug achado cedo é barato.
- Ordem: groundwork (schema, regras do Firebase, estrutura compartilhada) na 01; dados e API antes da tela que os consome; o resto por valor.
- Marque cada fatia com `· api`, `· tela`, `· mobile`, `· infra` ou `· dados` no título.
- Todo CA em pelo menos uma fatia; CA com parte servidor e parte tela aparece nas duas.
- Feature com mais de ~8 fatias ou ~10 dias: proponha ao responsável dividir em duas specs antes de seguir.

## 3. Escrever cada fatia (modelo `docs/specs/_modelo/plano.md`)
- **Tarefas** em ordem, com caminho completo dos arquivos.
- **Contratos públicos:** rotas (verbo, caminho, códigos), assinaturas de funções exportadas, DTOs/documentos com campos e tipos, nomes de coleções/tabelas, componentes e rótulos exatos na tela, permissão exigida.
- **Teste de cada CT:** nome (`CT-03: ...`), arquivo, por onde entra (caminho de produção) e o que confere (da coluna "Prova").
- **Valores esperados** de cálculos e validações em tabela, tirados da spec. Se a spec não dá o valor, pergunte; não calcule por conta própria.
- **Riscos** da fatia (ex.: índice composto no Firestore, migration expand/contract, regra de segurança a atualizar).
- Segurança: para cada item `[decisão]`/`[CA]` da skill `seguranca` que a spec cobre, a tarefa que o implementa.

## 4. Conferir
- `python3 scripts/harness/verificar_spec.py docs/specs/<NNN-nome>` verde (inclui: todo CA da spec aparece no plano).
- Painel preenchido com "Próximo passo exato: implementar fatia 01".

## 5. Retorno (até 12 linhas)
Fatias (número, título, tag), riscos, divergências entre spec e código encontradas, perguntas pendentes.

# Plano — NNN [Nome da feature]

- **Spec:** `./spec.md` · **Branch:** `feat/NNN-nome` · **Trilha:** padrão | crítica
- **Status:** planejado | em execução | bloqueado | concluído

## Painel (atualize a cada parada)
- **Feito:** [fatias concluídas, uma linha cada]
- **Falta:** [fatias pendentes]
- **Bloqueios / decisões pendentes:** [nenhum | pergunta objetiva + recomendação]
- **Próximo passo exato:** [ex.: "implementar fatia 02"]

## Impacto
- **Criar:** `caminho` — responsabilidade
- **Alterar:** `caminho` — o que muda
- **Riscos:** [ex.: migration com valor default; índice composto no Firestore; regra de segurança a ajustar]

## Fatias
Fatia = entrega vertical de 0,5 a 2 dias, demonstrável pelos seus testes, com os testes dentro da própria fatia. Ordem sugerida: dados e API antes da tela que os usa. Groundwork (schema, estrutura compartilhada) entra na fatia 01.

### [ ] Fatia 01 · api — [título]
- **Entrega:** CA-01, CA-02 · **Testes:** CT-01, CT-02
- **Tarefas** (ordem de execução):
  1. [arquivo e o que fazer; contrato público: rota/função/DTO/campos/tipos]
  2. Teste `CT-01: ...` em `caminho/do/teste` — entra por [porta de produção], confere [efeito].
- **Pronto quando:** CTs da fatia verdes e `check.sh` verde.

### [ ] Fatia 02 · tela — [título]
- **Entrega:** CA-03 · **Testes:** CT-03
- **Tarefas:**
  1. [componentes, hooks, rótulos exatos, estados]

## Decisões tomadas na implementação
- [AAAA-MM-DD] [decisão de uma linha e motivo]

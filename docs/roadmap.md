# Roadmap — Rootora 2.0

> Ordem por dependência e valor. Formato compatível com skill status. Data: 2026-11-24. A documentação não equivale a spec aprovada ou feature implementada. Todas começam a especificar; IDs 001–010 são novos no padrão docs/specs (pastas legadas mantidas). Escopo em [PRD](product-overview.md).

| Nº | Feature | Depende de | Tela? | Tamanho | Status |
|---|---|---|---|---|---|
| 001 | fundacao-visual | — | sim | M | a especificar |
| 002 | hoje-proximo-passo | 001 | sim | M | a especificar |
| 003 | controle-configuracoes | 001, 002 | sim | M | a especificar |
| 004 | biblioteca-cientifica | 001 | sim | M | a especificar |
| 005 | catalogo-atividades | 001, 002 | sim | M | a especificar |
| 006 | planos-se-entao | 005 | sim | M | a especificar |
| 007 | interceptacao-alternativas | 003, 005, 006 | sim | G | a especificar |
| 008 | evolucao-comportamental | 002, 005, 007 | sim | G | a especificar |
| 009 | onboarding-rootora-2 | 003, 004, 005, 008 | sim | M | a especificar |
| 010 | acabamento-e-recuperacao | 002, 003, 007, 008, 009 | sim | M | a especificar |

Status possíveis: a especificar → especificada → em implementação → em revisão → concluída.

P = pequena, M = média, G = grande (dividir se exceder ~10 dias ou 8 fatias). Tamanhos qualitativos, sem prazo prometido. Executar uma feature por vez; a tabela define a ordem recomendada mesmo onde há independência técnica. Não criar abas sem destino funcional.

## Entregas, limites e gates

| Feature | Entrega vertical e verificação principal | Trilha prevista (confirmar caminhos na spec) |
|---|---|---|
| 001 | Tokens, botões, campos, estados, ícones, tipografia e composição base; contraste e TalkBack, regressão de telas existentes; corrigir dívida de contraste do botão | padrão se só tema/componentes |
| 002 | Home orientada à ação, tarefas e Momento de foco/Estou travado acessíveis; sequência compacta, sem alteração de regras de conclusão | padrão; crítica se tocar caminhos nativos |
| 003 | Controle como aba, Perfil convertido em configurações; preserva regras, consentimentos, rotas, status e pendência para amanhã | crítica (PerfilScreen/permissões) |
| 004 | Biblioteca offline, lições finitas com fonte e limite; gate de revisão editorial; navegação Aprender | padrão, sem dados pessoais |
| 005 | Catálogo de atividades com filtros, escolha e conclusão explícita; reusar tarefas quando semântica permitir, definir persistência e integração | crítica se persistência/serviços tocados |
| 006 | Criar/editar/remover plano se–então e seleção previsível; sem diagnóstico; dados pessoais protegidos | crítica se dados/serviços tocados |
| 007 | Interceptação revisada com alternativa no momento oportuno; manter estados, acesso rápido/emergência, janela noturna e foco; validar fixtures e aparelho físico | crítica |
| 008 | Evolução com dados reais, fonte/período, cobertura, desistências e atividades; preservar desafios/reflexão e histórico; sem falsa estimativa de dopamina ou tempo poupado | crítica (coleta/Analytics) |
| 009 | Onboarding novo explica missão e primeira ação, sem reiniciar usuários existentes; manter gates e recusas de permissão | crítica |
| 010 | Feedback discreto, recuperação e fluxo completo; auditoria de acessibilidade/consistência, regressão física e prontidão para teste fechado | conforme caminhos, crítica se nativos/dados |

**Primeira feature a especificar:** 001-fundacao-visual. Aprovar tokens e amostras de tela antes de migrar toda a UI. Separar mudança de regra comportamental de refactor visual.

## Marcos de validação

- M1 (001–003): identidade e fluxo atual renovados, bloqueio continua funcionando; teste físico e avaliação rápida de usabilidade.
- M2 (004–007): aprender → escolher alternativa → agir no momento de impulso. Liberar ao teste fechado apenas conteúdo revisado e fluxos sem regressão; medir abandono e uso real.
- M3 (008–010): indicadores confiáveis, onboarding coerente, revisão de privacidade/legal quando aplicável, teste de atualização desde versão anterior. Decisão humana antes de publicar.

## Procedimento do harness (cada feature)

1. Especificar no chat ou skill iniciar-feature; esclarecer regras/decisões; spec autossuficiente no modelo, RN com fonte, CA Dado/Quando/Então, CT com prova, estados e mensagens.
2. Criar branch feat/NNN-nome a partir da main atualizada e docs/specs/NNN-nome/ (spec.md, plano.md, prototipo.html se tela, revisao.md). Não usar esta branch documental para implementar tudo.
3. Arquiteto planeja fatias verticais de 0,5–2 dias, testes na própria fatia, dados/contratos antes da UI que depende deles. Validar python3 scripts/harness/verificar_spec.py docs/specs/NNN-nome.
4. Implementar uma fatia, testar CTs, bash scripts/harness/check.sh, atualizar painel do plano e commitar. Sem inventar RN. Se trilha crítica, aplicar segurança e testes de integração/propriedade, Gradle e aparelho conforme impacto.
5. Revisão independente (qa ou qa-critico), corrigir bloqueantes; registrar melhorias não bloqueantes em docs/pendencias.md. Revisão APROVADO no commit atual e check completo antes do PR. Responsável decide merge/deploy; nunca push direto na main.
6. Atualizar fontes vigentes (regras de negócio, schema, arquitetura, design, glossário, textos legais quando necessário) no mesmo commit/feature. Atualizar status do roadmap após evidência real.

## Fora do roadmap atual

- Assinatura e preço: frente crítica separada, já planejada historicamente; não bloquear validação do núcleo 2.0 por cobrança. Definir prioridade comercial e abrir ID próprio após decisão.
- Programas guiados de 7/14/30 dias, IA, CMS, gamificação e múltiplos temas: adiar até sinais de valor.
- iOS, wearables, integrações externas: custo de manutenção e permissões.
- Alterar lógica de proteção/streak ou retirar válvulas: exige hipótese e aprovação próprias.
- Não prometer release por data sem especificação e capacidade confirmadas.

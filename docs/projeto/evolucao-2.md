# Rootora 2.0 — Diretrizes de evolução das regras

**Status:** proposta de requisitos, 2026-11-24. Este documento não substitui regras implementadas nem é uma spec aprovada. Cada mudança deve passar pelo esclarecimento do responsável, spec/plano/protótipo/revisão do harness. Atualizar as regras vigentes no commit da implementação, não antecipadamente.

## Invariantes de regressão

- Regra do dia cumprido (ao menos uma essencial explicitamente concluída), limite de três essenciais, proteção semanal, redução/retorno, histórico e desafios permanecem como estão. Aprender, atividade, uso de redes ou cronômetro não podem alterar o streak automaticamente.
- Pré-compromisso de alterações de bloqueio para o dia seguinte, sessão/cooldown/saldo, acesso rápido e emergência, rotina noturna e ordem de estados nativos mantêm contratos existentes.
- Momento de foco respeita prazo nativo e saída explícita, não conclui tarefa pelo timer, não bloqueia apps não selecionados. Sem permissão, não prometer bloqueio.
- Não mudar exclusão de conta, consentimento, notificações ou gates de onboarding por rearranjo visual. Preservar acessibilidade e Voltar.
- Textos pessoais não entram em Analytics; acesso por UID e exclusão de novos dados quando aplicável.

## Mudanças propostas por fluxo

| Fluxo | Manter | Proposta e limite |
|---|---|---|
| Hoje | CRUD, recorrência, essencial, conclusão e início | Próxima ação em destaque; sequência deixa de dominar; critério determinístico de escolha a definir |
| Controle | Seleção de apps, janela, regras, status, acesso de uso e rotina | Área própria com configuração original e estado real; sem aplicar configuração instantânea |
| Hábitos | Sugestões e tarefas recorrentes | Catálogo finito de leitura, movimento, atenção, conexão, criatividade, natureza, organização e descanso. Duração é estimativa de UX; atividade não se torna essencial sem ação explícita segundo regra vigente |
| Aprender | — | Lições finitas: explicação, impacto, ação, fonte, limite. Sem diagnóstico, feed ou geração automática |
| Plano se–então | Porquê e alternativa do dia | Plano opcional de gatilho/ação; não substitui regra de seleção até aprovação |
| Interceptação | Máquina de estados e válvulas | Alternativa apropriada ao estado, CTA de desistência quando aplicável; leitura científica curta e opcional, sem fricção adicional não aprovada |
| Evolução | Histórico semanal, desafios, resumo de redes, reflexão | Indicadores reais; períodos comparáveis; sem dados = indisponível, nunca inventar economia de tempo |
| Configurações | Conta, porquê, lembrete, tutorial, termos/exclusão | Acesso pelo cabeçalho; nada perdido ou escondido |
| Retorno | Proteção e recuperação | Feedback visual discreto, sem reduzir regras vigentes |

## Questões de negócio a resolver antes de cada spec

- Como selecionar próxima tarefa quando há várias; qual comportamento sem essenciais pendentes?
- Atividade é sessão separada, tarefa comum ou ambas com relação explícita? Qual ação registra conclusão, como evitar duplicação, editar/desfazer, sincronizar e excluir?
- Planos: quantidade ativa, gatilhos permitidos, relação com app/tarefa/atividade, prioridade e fallback quando não houver correspondência.
- Interceptação: em quais estados a alternativa aparece, como voltar/encerrar, o que acontece com saldo, sessões e prazo de foco; sem desvio das regras vigentes.
- Conteúdo: quais lições revisadas entram, quem revisa, quando corrigir/remover e como mostrar fonte offline.
- Métricas: evento elegível, denominadores, deduplicação, cobertura mínima, fuso, períodos parciais, retenção e dados ausentes.
- Onboarding de usuário novo vs existente; manutenção do gate de ativação e consentimentos já concedidos.
- Redução de celebrações: o que passa a ser inline sem prejudicar recuperação e acessibilidade.
- Monetização: preço, trial, acesso após expiração e segurança em spec própria.

## Critérios transversais para todas as features

Cada CA observável deve ter CT com prova pelo caminho de produção. Testar vazio, erro, offline, retorno, toque duplo, permissões, outro UID e concorrência quando aplicáveis. Testar TalkBack, texto ampliado e contraste. Mudança na interceptação exige fixtures TS/Kotlin e ensaio em Android físico, inclusive fundo, prazo expirado, Voltar, permissões removidas e emergência. O teste fechado precisa avaliar valor percebido e segurança antes da versão pública.

Não alterar as regras acima por este documento; vincular [roadmap](../roadmap.md), [PRD](../product-overview.md), [design](../design-system.md) e [ciência](ciencia-rootora-2.md).

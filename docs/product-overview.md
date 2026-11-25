# PRD — Rootora 2.0

- **Tipo:** aplicativo mobile Android, B2C, por assinatura.
- **Versão deste documento:** 2.0 · 2026-11-24.
- **Estado:** proposta de evolução consolidada a pedido do responsável; aprovação granular e implementação por feature ainda pendentes. Não descreve funcionalidades já publicadas quando indicadas como novas.
- **Referência vigente:** [spec original](projeto/spec.md), [regras de negócio](projeto/regras-de-negocio.md), [schema](projeto/schema.md). A especificação aprovada de cada feature prevalece sobre ideias deste PRD. Atualizar os documentos vigentes no mesmo commit da implementação.

## Problema e proposta de valor

Pessoas recorrem automaticamente ao celular para aliviar tédio, desconforto ou resistência a uma tarefa. A rolagem pode deslocar sono, atenção e atividades importantes. Bloquear apps ajuda a interromper o ciclo, mas não oferece por si só uma alternativa significativa. O Rootora combina fricção voluntariamente configurada, pequenas ações, educação fundamentada na ciência e substituição de hábitos. Não é tratamento de dependência, diagnóstico ou medidor de dopamina.

**Missão:** ajudar pessoas a recuperar o controle da atenção, enfrentar a procrastinação e trocar comportamentos automáticos por hábitos mais saudáveis, com autonomia e evidências científicas.

**Posicionamento:** menos estímulos, mais vida. O sucesso é viver melhor fora do app, não maximizar tempo dentro dele.

## Personas

- Adulto que trabalha ou estuda e usa redes sociais quando uma tarefa parece difícil; quer voltar ao trabalho em poucos minutos.
- Adulto que abre o celular por hábito, tédio ou à noite; quer controlar as distrações e recuperar tempo para descanso, movimento e relações.
- Adulto interessado em entender os próprios hábitos, sem linguagem clínica, culpa ou promessas milagrosas.

Público inicial 18+, Android, português do Brasil. Não presumir transtornos, dependência, diagnóstico ou causa individual.

## Pilares e ciclo

| Pilar | Valor |
|---|---|
| Conscientizar | Entender recompensa, atenção, regulação emocional e hábitos em lições curtas. |
| Interromper | Criar uma oportunidade real de escolha antes da abertura automática. |
| Substituir | Facilitar atividades fora da tela e passos pequenos de tarefas. |
| Evoluir | Observar comportamentos reais, ajustar estratégias, retornar sem vergonha. |

Gatilho → intervenção existente → escolha consciente permitida pelas regras → tarefa/atividade ou uso intencional permitido → reflexão opcional. Nunca oferecer uma ação que burle cooldown, saldo, sessão, janela noturna, pré-compromisso ou permissões.

## Escopo da versão 2.0

### Inclui

| Capacidade | Hoje | Alvo 2.0 |
|---|---|---|
| Hoje | Tarefas essenciais, recorrentes, contador de sequência, cooldown | Próxima ação prioritária, tarefas e foco, contexto do controle; sequência compacta em Evolução |
| Controle | Bloqueio e rotina noturna dentro de Perfil | Área própria, estado real das permissões, apps, sessões e alterações pendentes |
| Momento de foco e Estou travado | Fluxos existentes | Preservar lógica, renovar UI e tornar acesso fácil |
| Interceptação | Pausa, sessão, cooldown, válvulas e alternativa do dia | Interface mais clara; integrar alternativas sem afrouxar regras |
| Hábitos | Sugestões fixas no AddTaskForm, recorrência | Catálogo curado por contexto e duração, plano opcional se–então, conclusão explicitamente registrada |
| Aprender | Não há biblioteca científica na UI | Lições finitas, leitura breve, referências, limitações e revisão editorial |
| Evolução | Histórico, desafios, uso de redes e reflexão semanal | Indicadores comportamentais com origem, períodos e ausência de dados explícitos |
| Recuperação | Proteção, retorno após pausa e raiz | Manter regras, reduzir pressão visual e celebrações interruptivas |
| Perfil | Aba principal | Configurações acessíveis pelo cabeçalho; preservar conta, porquê, lembretes, tutorial e direitos de privacidade |
| Onboarding | Fluxo de ativação existente | Explicar os quatro pilares e oferecer primeira ação sem repetir o fluxo para usuários existentes |

### Jornadas desejadas

1. Abrir Hoje → escolher uma tarefa pendente → iniciar Momento de foco → parar ou registrar conclusão explicitamente.
2. Abrir app selecionado → interceptação respeita o estado vigente → desistir e escolher uma atividade, voltar à tarefa ou prosseguir somente quando permitido.
3. Abrir Hábitos → selecionar contexto/duração → escolher atividade → sair da tela para realizá-la → marcar feita opcionalmente.
4. Abrir Aprender → escolher tema → ler conteúdo curto com fonte e limitações → experimentar uma ação ou fechar.
5. Revisar Evolução → comparar períodos com dados disponíveis → ajustar plano; não penalizar recaídas.

### Não inclui

- IA gerando aconselhamento ou artigos científicos; feed infinito, rede social, ranking, XP, moedas, recompensas aleatórias.
- Detox/reset de dopamina, pontuação cerebral, diagnóstico, testes de saúde mental ou promessa de cura.
- Mudança das regras do streak, proteção, saldo, acessos rápidos/emergência ou regras noturnas por simples redesign.
- Novo backend, microsserviços, wearables, iOS, multi-tema, integração com calendário ou conteúdo religioso nesta fase.
- CMS administrativo, recomendações algorítmicas e programas guiados de 7/14/30 dias antes de validar o núcleo.
- Implementação de assinatura como dependência técnica do redesign: frente própria, sujeita a aprovação comercial e jurídica.

## Modelo de cobrança

Manter como intenção vigente assinatura integral do app e oferta inicial de 7 dias, descritas na spec original, sem definir preço nesta entrega. Validar disposição a pagar, custos de loja, Firebase, suporte e conversão antes da publicação paga. Não migrar Firebase para Blaze nem ativar cobrança por este PRD. Compra, restauração, cancelamento e autorização de acesso exigem feature crítica própria. Acesso a dados da conta, exclusão e saídas de segurança não devem depender de um paywall.

## Métricas de sucesso

- **Principal proposta:** variação do tempo diário médio em apps-alvo, comparando janelas equivalentes de 7 dias com cobertura suficiente de dados. Usar baseline anterior quando disponível; definir cobertura mínima na spec antes de publicar.
- Desistências explicitamente observadas / intervenções elegíveis; não confundir processo encerrado, ausência de evento e desistência.
- Atividades marcadas como realizadas pelo usuário; não inferir execução a partir de toque ou tempo decorrido.
- Sessões de foco iniciadas/concluídas conforme eventos reais, dias ativos acumulados e tarefas essenciais concluídas.
- Retenção D7 (métrica histórica) como diagnóstico secundário, não meta de tempo no Rootora.
- Guardrails: falhas de bloqueio, abandono da intervenção, acessibilidade, estabilidade, privacidade e feedback qualitativo sobre autonomia.

Sem metas numéricas inventadas. Medir baseline e amostra do teste fechado antes de fixar metas; não atribuir causalidade a comparação antes/depois. Sem acesso de uso, mostrar indisponibilidade, nunca zero presumido.

## Restrições e requisitos transversais

- Stack existente, modo offline para conteúdo estático, nenhuma nova permissão sem decisão.
- LGPD, minimização de dados, isolamento por UID, exclusão da conta e revisão legal quando novos dados forem coletados; sem texto pessoal no Analytics/Crashlytics.
- TalkBack, fonte ampliada, contraste WCAG AA, alvos de toque 48 dp, redução de movimento.
- Biblioteca científica com autoria, publicação, DOI/URL, população, evidência e limitações; revisão profissional antes de publicar. Ver [fundamentação e governança editorial](projeto/ciencia-rootora-2.md).
- Uma ação principal por tela, sem tom moralista ou compulsivo. Identidade em [design system 2.0](design-system.md).
- [Arquitetura](architecture.md) e [roadmap](roadmap.md); [diretrizes de evolução das regras](projeto/evolucao-2.md).

## Decisões a fechar por feature

Taxonomia final, critérios de registro e sincronização de atividades, planos ativos e prioridade de seleção, tratamento de alternativas na interceptação, cobertura de métricas, dados a reter, política editorial e revisão, preço e oferta. As propostas deste documento não são autorização para inventar regras ou alterar produção.

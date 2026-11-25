# Design System — Rootora 2.0 · Raiz

> Direção visual proposta para as features 2.0. O [design system implementado](projeto/design-system.md) continua a descrever o app atual até a migração por feature. Este arquivo é a referência visual de destino para a skill prototipar; para manutenção 1.x, usar os tokens vigentes. Em divergência de fluxo, vale a spec aprovada.

## Conceito

Menos ruído, mais intenção. Estética editorial, orgânica, contemporânea: contraste forte, espaços generosos, um foco por tela e ilustração linear de raízes. Preservar a metáfora de fundação e recaída sem vergonha; não transformar a raiz em barra de punição. Não mudar o ícone do launcher nesta fase.

## Tokens propostos

| Token semântico | Hex | Uso |
|---|---|---|
| background / casca | #F4F1E9 | Fundo |
| surface / papel | #FFFDF7 | Leitura, cards |
| surfaceSelected / salvia | #DCE7D6 | Seleção, apoio positivo |
| action / musgo | #344A39 | CTA, navegação ativa, fundo imersivo |
| textPrimary / terraEscura | #252B23 | Texto principal |
| textSecondary / terraSuave | #62685B | Texto secundário em fundo claro |
| accent / cobre | #B5772E | Detalhe de raiz, não texto pequeno sobre fundo claro |
| border | #D1D1C5 | Separadores decorativos |
| controlBorder | #62685B | Limites de controles quando necessários |
| error | #B5473A | Erro com mensagem/ícone, não punição |
| onAction | #FFFDF7 | Texto em verde escuro |
| onImmersiveMuted | #DCE7D6 | Texto auxiliar na superfície escura |

Preservar aliases e migrar consumidores em src/theme/colors.ts; não trocar valor de accent e manter botão cobre acidentalmente. A primeira feature deve conferir pares de contraste, estados disabled, ícones e texto; a borda decorativa não serve como única indicação de controle. Cobre em até um ponto focal por tela. Não usar gradientes decorativos ou sombras pesadas.

## Tipografia

Manter fontes locais já vinculadas (src/theme/typography.ts): Zilla Slab Medium/SemiBold para display e títulos editoriais; IBM Plex Sans Regular/Medium/SemiBold para interface; Space Mono Regular apenas datas e números auxiliares. Não carregar fontes da internet.

| Estilo | sp | Entrelinha sugerida |
|---|---:|---:|
| Display | 36 | 42 |
| Título | 28 | 34 |
| Seção | 20 | 26 |
| Corpo / botão | 16 | 24 |
| Auxiliar | 14 | 20 |
| Legenda | 12 | 16 |

Respeitar fontScale; não cortar texto ou desativar escala. Números de timer com largura estável, sem tremor visual. Evitar caixa alta extensa.

## Espaçamento, formas e acessibilidade

- Escala 4/8/12/16/20/24/32/40 dp; margem lateral 20 dp (16 em tela estreita).
- Raio: pequeno 12, médio 16, grande 24, hero 28, pill completo. Cards sem borda repetitiva se a separação espacial bastar.
- Alvo de toque mínimo 48×48 dp (supera o mínimo 44 do harness), botão principal altura mínima 52 dp, sem altura fixa para texto ampliado.
- Contraste WCAG AA: 4,5:1 texto normal, 3:1 texto grande e controles relevantes. Validar todos os estados; não depender de cor. TalkBack com ordem lógica, role, label, selected/checked e feedback acessível.
- Safe areas superior/inferior, teclado não cobre ação, rolagem quando necessária; validar 320–430 dp, fonte 200%, Android Voltar.
- Lucide 20–24 dp, traço consistente; ícone não substitui rótulo. Animações de 150–250 ms quando úteis, respeitar redução de movimento; sem confete ou vibração obrigatória.
- Sem feed infinito, contagem regressiva comercial artificial ou dark patterns. Foco e interceptação usam superfície verde escura, não um tema escuro global.

## Componentes e estratégia

| Componente | Reuso/alteração |
|---|---|
| PrimaryButton, SecondaryButton, TextField | Reusar e revisar contraste, estados, acessibilidade e tamanho |
| RootProgressIcon | Preservar variantes; assinatura discreta na Home, maior em Evolução |
| HomeHeader, StreakCard | Cabeçalho funcional, ação de configurações; cartão de sequência deslocado/compactado |
| TaskList, TaskItem, AddTaskForm | Preservar regras e recorrência; ações começar/concluir distintas |
| TaskActionsSheet, RecurringTaskActionSheet | Reusar para edição e ações, confirmar exclusão |
| CooldownBanner, InterceptLayout, ContagemEspera, ValvulaRow | Reusar estados e contratos; reestilizar sem alterar tempos ou autorização |
| Selo, ToggleIndicator, EmptyState, LoadingIndicator, Toast | Padronizar status não dependente de cor, feedback breve |
| ChallengeCard, DayStatusPill, ResumoRedesCard, ReflexaoSemanalSheet | Reorganizar em Evolução; sempre mostrar período e fonte |
| TaskCompletedOverlay, RootWateringOverlay, StreakMilestoneModal | Propor feedback discreto; manter semântica de conclusão e recuperação |
| Novos (a criar por spec) | NextActionCard, ActivityCard, LessonCard, EvidenceSource, PlanCard, MetricCard, PermissionStatus |

Uma ação primária por contexto. Ações secundárias texto/outline, destrutivas confirmadas; acesso de segurança não pode ficar escondido. Inputs com label persistente e erro textual. Bottom sheet rolável com foco restaurado no fechamento. Não criar biblioteca paralela de componentes.

## Navegação proposta

Hoje · Controle · Hábitos · Aprender · Evolução. Ícone de configurações no cabeçalho leva ao perfil existente. Barra inferior com ícone e texto, indicador ativo em sálvia, sem botão central gigante. Preservar rotas de notificação, gates, Voltar e InterceptActivity separada. Introduzir abas novas somente quando houver funcionalidade real; nenhuma aba vazia para promessa futura.

## Composição por tela

| Tela | Hierarquia e ação principal | Estados obrigatórios conforme spec |
|---|---|---|
| Hoje | Saudação discreta → próximo passo → tarefas essenciais/recorrentes → contexto do controle; Iniciar foco | Carregando, sem tarefa, pendente, cumprido, cooldown, recuperação |
| Controle | Status do serviço real → regras/aplicativos → janela e rotina noturna → detalhes de sessões; configurar/salvar | Carregando, sem permissão, ativo/desativo, alteração vale amanhã, erro |
| Hábitos | Plano pessoal se houver → filtros duração/contexto → catálogo finito; escolher atividade | Sem plano, vazio, preenchido, offline, erro quando aplicável |
| Detalhe de atividade | Título, duração sugerida, instruções, sair para fazer; registrar conclusão opcional | Não iniciada, concluída, voltar sem conclusão |
| Plano pessoal | Se [gatilho], então [ação]; salvar | Criar, editar, conflito/erro, sem plano |
| Aprender | Trilha finita e progresso opcional; ler lição | Conteúdo disponível, vazio, fonte indisponível sem rede |
| Lição | Título editorial → 1 ideia → prática → evidência e limites → fontes | Leitura offline, link externo, texto ampliado |
| Evolução | Período → tempo de uso medido → escolhas/atividades/foco → raiz, desafios, reflexão | Sem cobertura, sem permissão, sem histórico, parcial, dados disponíveis |
| Interceptação | Fundo musgo, nome do app, estado/contagem real, decisão permitida; alternativa adequada ao estado | Pausa, sessão, cooldown, saldo esgotado, noturno, válvulas, foco ativo, emergência |
| Foco/Estou travado | Tarefa, 2/5/10 min conforme regra vigente, timer, parar/continuar/concluir conforme estado | Seleção, contagem, concluída, interrompida, sem bloqueio efetivo |
| Configurações | Conta, porquê, notificações, permissões, tutorial, termos e privacidade | Carregando, alteração salva/erro, reauth, exclusão |
| Onboarding/auth | Explicação curta, primeira tarefa/controle; ação de seguir | Gates existentes, validação, recusa de permissão, retorno |

## Microcopy

Frases curtas, não moralistas; sem exclamações, linguagem de perda ou culpa. Exemplos conceituais (spec fixa rótulo exato): “Volte ao que importa”, “Começar por 2 minutos”, “Escolher outra atividade”, “Tempo de uso indisponível”. Não dizer “dopamina baixa”, “cérebro recuperado” ou “proteção” fora do significado de streak.

## Prototipagem e migração

Cada feature com UI tem docs/specs/NNN-nome/prototipo.html autocontido, CSS variables com estes tokens, seletor de telas/estados, moldura ~390×844 e rodapé “Protótipo com dados ilustrativos. A especificação prevalece.” Sem dependência externa; fontes de fallback declaradas. Cobrir todos os CA visuais, não apenas happy path. Protótipos 1.x em docs/design/prototipo são históricos até sua migração; não recolorir para fingir implementação. A primeira feature deve fechar os tokens e validar em aparelho, atualizar docs/projeto/design-system.md e os componentes efetivamente migrados, preservando documentação dos fluxos ainda legados. Não aprovar a UI apenas por screenshot.

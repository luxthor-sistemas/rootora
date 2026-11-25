# Arquitetura e Stack — Rootora

> Entrada técnica do harness. O inventário detalhado e vigente é [docs/projeto/arquitetura.md](projeto/arquitetura.md); [schema vigente](projeto/schema.md), [boas práticas](projeto/boas-praticas.md) e [regras](projeto/regras-de-negocio.md) completam a referência. A seção de evolução abaixo é proposta, não implementação.

## Estilo e stack vigente

App React Native CLI (bare), TypeScript, Android/Kotlin e Firebase gerenciado. React Navigation, lucide-react-native, Animated do core, AsyncStorage e notificações locais Notifee; Auth, Firestore, Analytics e Crashlytics. Sem servidor próprio. Google Play distribui o app. Versões e detalhes no inventário vigente e manifestos, sem duplicar números.

| Camada | Local |
|---|---|
| UI e navegação | src/screens, src/components, src/navigation, src/theme |
| Orquestração de fluxos | src/hooks |
| Regras puras | src/domain |
| Persistência e observabilidade | src/services, src/utils |
| Ponte nativa | src/native, android/app/src/main |
| Regras de acesso | firestore.rules |
| Documentação e specs | docs/projeto, docs/specs, docs/adr, docs/legal |

## Acesso e contratos críticos

Conta individual Firebase Auth; dados do usuário isolados por UID nas regras Firestore, não só na UI. Acesso e escrita por caminho/ID devem validar dono. Nenhum dado de outro usuário, segredo ou texto livre em log/Analytics/Crashlytics. Não ampliar permissões nem expor coleções em nome do redesign.

O motor Kotlin permanece autoridade para sessão/cooldown e interceptação mesmo sem JS; a referência TypeScript usa fixtures compartilhadas. InterceptActivity monta root RN separado. Momento de foco usa prazo absoluto nativo; encerrar/expirar libera o modo temporário sem marcar tarefa. UsageStatsManager é fonte de uso conforme ADR-0001; acesso de uso e acessibilidade são permissões distintas. Não inferir zero nem prometer bloqueio sem autorização.

## Evolução 2.0 (proposta, fechar em cada spec)

| Área | Abordagem recomendada | Condição |
|---|---|---|
| Tema/navegação | Reusar tokens, componentes e stacks; migrar por fatia; configurações mantém rotas e gates | Sem nova biblioteca ou mudança do pacote |
| Aprender | Conteúdo editorial estático versionado no app, offline, IDs estáveis, fontes estruturadas e versão/revisão | Definir formato, política de atualização e gate editorial na spec |
| Hábitos | Catálogo curado estático; reusar domínio de tarefas quando a semântica for idêntica | Não criar segunda fonte de conclusão, nem confundir atividade com essencial |
| Plano se–então | Preferir modelo pequeno, sem IA, seleção determinística definida na spec | Decidir persistência, prioridade, edição, limites, exclusão e isolamento |
| Interceptação | Adaptar renderização e sugestões no root existente, sem segunda máquina de estado | Testes de paridade Kotlin/TS e aparelho físico |
| Evolução | Reusar dados existentes e adicionar eventos mínimos apenas se necessários | Cobertura, deduplicação, origem e privacidade antes de instrumentar |

Não fixar nomes de coleções/campos ou migrações neste documento. Persistência local vs. Firestore de novos registros requer decisão por feature (sincronização entre dispositivos, exclusão e offline); evitar nova infraestrutura paga. Se Firestore mudar, atualizar schema, regras, testes de autorização, privacidade e estratégia compatível com clientes antigos na mesma feature. Não adicionar dados clínicos.

## Padrões transversais

- Datas: respeitar convenções locais atuais (dia local e histórico); não misturar UTC com dia do usuário. Definir fronteiras de período e fuso na spec de métricas.
- Offline: conteúdo estático disponível; estado não confirmado deve ser distinto de salvo; retries idempotentes se houver escrita. Erros claros e sem vazamento.
- Analytics: eventos mínimos de comportamento, sem texto de intenção, porquê, plano pessoal ou diagnósticos; novo campo/evento exige avaliação de privacidade.
- Testes: Jest (incluindo domínio e UI), tipos/lint via harness; Gradle para Kotlin, fixtures compartilhadas e aparelho físico nas features nativas. Acessibilidade e regressões de navegação obrigatórias.
- Ambientes: preservar configuração atual; nenhum deploy, alteração de produção, migration ou Blaze sem aprovação explícita.
- Assinatura futura é crítica, com verificação de entitlement no servidor e custo/regras próprios; não é requisito de infraestrutura da UI 2.0.

## ADRs

| Nº | Título | Status |
|---|---|---|
| 0001 | [Coleta de uso via UsageStatsManager](adr/0001-coleta-uso-usagestatsmanager.md) | Vigente |

Nenhum ADR novo: não há decisão técnica difícil de reverter aprovada nesta etapa. Registrar ADR apenas se houver trade-off real e critérios do harness; decisões menores na spec/plano.

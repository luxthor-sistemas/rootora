---
name: stack-react-native
description: Padrões para apps React Native com Expo - navegação, estado de servidor, armazenamento seguro, offline, permissões do sistema, desempenho de listas, testes e builds EAS. Use ao criar ou alterar telas, navegação ou recursos nativos do app mobile.
---

Defaults. Se `docs/architecture.md` diz diferente, ele vence.

## Estrutura
- Expo (managed + dev client) com Expo Router (ou React Navigation, se já usado). Rotas em `app/`, telas de domínio em `features/<area>/`, componentes genéricos em `ui/`, acesso a dados em `api/`/`data/`.
- TypeScript estrito. Telas não chamam `fetch`/SDK direto: hooks da camada de dados (TanStack Query ou equivalente).

## Regras
- Credenciais e tokens só em `expo-secure-store`. `AsyncStorage`/MMKV só para dado não sensível (preferências, cache).
- Dado local (SQLite/MMKV): esquema versionado com migração; trate o app aberto com versão antiga dos dados.
- Offline: defina na spec o que funciona sem rede; mutações com fila/retry idempotente; estado "sem conexão" visível.
- Permissões do sistema (notificação, câmera, localização): pedir no momento do uso, com explicação antes; tratar "negado" e "negado para sempre" (levar às configurações).
- Notificações e alarmes: agendamento local com `expo-notifications`; considere limites do iOS (64 agendadas) e economia de bateria do Android; teste em aparelho real.
- Listas: `FlatList`/`FlashList` com `keyExtractor` estável, sem `ScrollView` com `map` para listas longas; memoize itens.
- Safe areas, teclado (`KeyboardAvoidingView`), alvos de 44 pt, Dynamic Type/escala de fonte, rótulos de acessibilidade (`accessibilityLabel`, `accessibilityRole`).
- Nada de segredo no app: tudo em `EXPO_PUBLIC_*` e no bundle é público. Chamadas privilegiadas passam por backend/Cloud Function.
- Deep links validados (não confiar em parâmetros da URL).

## Builds
- Versões e perfis em `eas.json`; `app.config.ts` lê ambiente. Atualização OTA (`expo-updates`) só para JS compatível com o runtime publicado.
- **Build de produção, submit e publicação de update são do responsável ou do CI**: o hook bloqueia `eas submit` e `eas update` em produção.

## Testes
Jest + React Native Testing Library (comportamento, não snapshot). Fluxos críticos com Maestro. Antes de PR de feature com recurso nativo, teste em aparelho real iOS e Android e registre no PR.

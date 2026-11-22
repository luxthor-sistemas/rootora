---
name: stack-firebase
description: Padrões para projetos Firebase - Firestore (modelagem, regras, índices, transações), Auth com custom claims, Cloud Functions, Storage, emuladores e deploy. Use ao criar ou alterar coleções, regras, functions ou integração com Firebase.
---

Defaults. Se `docs/architecture.md` diz diferente, ele vence.

## Modelagem e acesso
- Multi-tenant: dados sob `tenants/{tenantId}/...` ou campo `tenantId` obrigatório em todo documento, com regra que confere contra o claim do usuário. Escolha uma forma por projeto (está no `architecture.md`).
- Tenant e papel em **custom claims** definidos só pelo servidor (Admin SDK em Cloud Function). Nunca confiar em campo enviado pelo cliente.
- Acesso ao Firestore encapsulado num módulo de dados (`api/` ou `data/`), com conversores tipados (`withConverter`) e validação (Zod) na leitura de dados críticos.
- Escrita que mexe em vários documentos ou contadores: `runTransaction`/`writeBatch` ou `FieldValue.increment`. Nada de ler-modificar-escrever solto.
- Regra de negócio crítica (preço, saldo, status, permissões, e-mail/notificação, integração com terceiros) roda em **Cloud Function**, não no cliente.
- Consulta nova com filtro composto: índice em `firestore.indexes.json` no mesmo commit.
- Paginação por cursor (`startAfter`), com `limit` sempre.

## Regras de segurança (`firestore.rules`, `storage.rules`)
- Negar por padrão. Regra por coleção, separando `read` em `get`/`list` e `write` em `create`/`update`/`delete` quando diferem.
- Validar campos permitidos (`request.resource.data.keys().hasOnly([...])`), tipos, tamanhos, e campos imutáveis (`tenantId`, `criadoPor`, `criadoEm`).
- Funções auxiliares (`estaNoTenant()`, `temPapel()`) no topo do arquivo.
- Toda mudança de estrutura vem com mudança de regra **e** teste no emulador (`@firebase/rules-unit-testing`): dono pode, outro tenant não pode, anônimo não pode, campo proibido recusado.

## Cloud Functions
- Callables/HTTP: verificar `context.auth`/token, validar entrada com Zod, conferir tenant e papel, responder erro genérico (`HttpsError`).
- Triggers idempotentes (podem disparar mais de uma vez): use o ID do evento ou um marcador no documento.
- Segredos com `defineSecret`/Secret Manager, nunca em código ou `.env` versionado.
- Região definida explicitamente (ex.: `southamerica-east1`), timeout e memória conscientes; evite cold start em fluxo crítico com `minInstances` só se medido.

## Ambientes e deploy
- Desenvolvimento e testes sempre nos emuladores (`firebase emulators:exec`). Projetos separados para dev/homologação/produção (`.firebaserc` com aliases).
- **Deploy é do responsável ou do CI**: o hook bloqueia `firebase deploy` para o agente.

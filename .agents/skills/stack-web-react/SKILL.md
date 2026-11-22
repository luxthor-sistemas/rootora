---
name: stack-web-react
description: Padrões para frontend web React + TypeScript (Vite ou Next.js) - camadas, acesso a API, estado de servidor, formulários, design system, acessibilidade e segurança no cliente. Use ao criar ou alterar telas e componentes web.
---

Defaults. Se `docs/architecture.md` diz diferente, ele vence.

## Camadas
- `ui/` — componentes genéricos do design system (Button, Field, DataTable, Dialog). Bibliotecas de terceiros (tabela, data, gráfico, ícone) só através de componentes daqui.
- `features/<area>/` — telas e componentes de domínio, organizados como as specs.
- `api/` (ou `data/`) — cliente HTTP/SDK e hooks de dados. **Telas não chamam `fetch`, SDK do Firebase nem cliente HTTP direto**: usam hooks desta camada.
- `app/` — rotas, layout, sessão, guarda de permissão.

## Regras
- TypeScript estrito; sem `any` novo (use `unknown` + validação).
- Estado de servidor com TanStack Query (ou o equivalente já usado): chaves por recurso, invalidação após mutação. No logout/troca de tenant: limpar todo o cache (`queryClient.clear()`).
- Formulários com React Hook Form + Zod (ou o que o projeto usa). Validação no cliente é conveniência; o servidor é a autoridade.
- Estilo só por tokens e componentes do `ui/`; nada de cor, fonte ou espaçamento solto na tela.
- Todo dado assíncrono trata carregando, vazio e erro. Mensagens com o texto da spec.
- Permissão no cliente só esconde/desabilita; acesso negado por URL mostra estado "sem permissão".
- Dinheiro chega como inteiro/texto da API e é formatado com `Intl.NumberFormat('pt-BR', ...)`; nenhum cálculo de valor na tela. Datas com fuso explícito.
- Acessibilidade: elementos nativos (`button`, `label`, `a`), foco visível, navegação por teclado, `aria-*` só quando o nativo não resolve.
- Segurança: nada de segredo no bundle (todo `VITE_`/`NEXT_PUBLIC_` é público); sem `dangerouslySetInnerHTML` sem sanitizador; links externos com `rel="noopener noreferrer"`.
- Next.js: dado sensível só em Server Components/Route Handlers com verificação de sessão; Server Actions validam entrada e permissão como qualquer endpoint.

## Testes
Testing Library por comportamento (role, label, texto), MSW para a API. Não testar detalhe de implementação nem snapshot grande.

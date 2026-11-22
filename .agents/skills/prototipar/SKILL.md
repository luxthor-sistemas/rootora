---
name: prototipar
description: UX. Gera ou refaz o prototipo.html autocontido de uma feature com tela, a partir da seção Telas da spec e do docs/design-system.md, com seletor de telas e estados. Use quando a spec tem tela e o protótipo falta ou precisa mudar. O caminho normal é o protótipo vir pronto do chat.
argument-hint: "<NNN-nome>"
---

O protótipo serve para o responsável **ver e aprovar fluxo e layout**. Não é código de produção e não decide regra: em divergência, vale a spec.

## Entrada
- `docs/specs/<NNN-nome>/spec.md`: objetivo, regras, CA e seção "Telas". "Sem tela.": pare e avise.
- `docs/design-system.md` (tokens e princípios). Se o projeto tem arquivo de tokens/componentes no código, use os mesmos nomes; leia por busca, não o arquivo inteiro.

## Escrita: um único `docs/specs/<NNN-nome>/prototipo.html`
- Autocontido: HTML + CSS + JS mínimo num arquivo, abre direto no navegador, sem rede e sem `fetch`. Tokens do design system como variáveis CSS no topo; nada de cor/espaçamento solto.
- Barra discreta no topo: "Protótipo — NNN nome" + seletor de tela e de estado (inicial, preenchido, carregando, vazio, erro de validação, erro de conexão, sem permissão, sucesso — os que a spec prevê).
- Mobile (React Native): moldura de celular (~390×844), safe areas, teclado sobre o formulário quando relevante.
- Textos, rótulos e mensagens **exatamente** como na spec. Dados fictícios plausíveis; nunca dado real.
- Princípios do `docs/design-system.md`: uma ação principal por tela, status com texto/ícone além da cor, foco visível, alvos de 44 px.
- Rodapé fixo: "Protótipo com dados ilustrativos. A especificação prevalece."

## Conferência
- Toda tela da spec existe e todo CA de tela tem um estado visível.
- Se houver navegador/Playwright disponível, abra e confira que renderiza sem erro no console; senão, diga isso no retorno.

## Retorno (até 6 linhas)
Caminho, telas e estados, o que não foi coberto.

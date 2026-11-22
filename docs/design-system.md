# Design System

> Referência visual única para protótipos (chat e skill `prototipar`) e para as telas. Se o projeto não tem UI, escreva "Sem interface visual." e apague o resto.

## Princípios
1. Uma ação principal por tela.
2. Todo status tem texto ou ícone além da cor.
3. Estados sempre previstos: carregando, vazio, erro, sucesso, sem permissão.
4. Alvos de toque de 44 px; foco visível; funciona só com teclado (web).

## Tokens
| Token | Valor | Uso |
|---|---|---|
| `--cor-acao` | | botão principal, links |
| `--cor-fundo` | | |
| `--cor-texto` | | |
| `--cor-erro` / `--cor-sucesso` / `--cor-alerta` | | |
| `--fonte-base` | | |
| `--espaco-1..6` | | escala de espaçamento |
| `--raio` | | bordas |

Arquivo de tokens no código: [PREENCHER: ex. `src/ui/tokens.css` ou `theme.ts`].

## Componentes
| Componente | Onde está no código | Observação |
|---|---|---|

## Padrões de tela
- Listagem: [tabela densa / cartões; filtros; paginação]
- Formulário: [validação inline, mensagens, botão de envio]
- Mobile: [navegação, safe areas, teclado]

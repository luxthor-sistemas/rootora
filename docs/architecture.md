# Arquitetura e Stack

> Fonte de verdade técnica. Mantida pela skill `arquitetura`. Decisões difíceis de reverter viram ADR em `docs/adr/`.

## Estilo arquitetural
[Ex.: monólito modular; app React + Firebase sem backend próprio; app RN + API. Princípio de organização em 2 linhas.]

## Stack
| Camada | Escolha | Versão / observação |
|---|---|---|
| Linguagem / runtime | | |
| Frontend web / mobile | | |
| Backend / funções | | |
| Banco de dados | | |
| Autenticação | | |
| Armazenamento de arquivos | | |
| Infra / deploy | | |
| Observabilidade (logs, erros) | | |

## Mapa de diretórios
```text
[estrutura real das pastas de código, testes e infra]
```

## Multi-tenant e acesso
[Como o tenant/dono é identificado, onde o filtro é aplicado (consulta, regra do Firebase), papéis e permissões.]

## Fluxos principais
[2 a 4 fluxos críticos em poucas linhas cada: autenticação, operação central, integrações.]

## Padrões transversais
- **Erros:** [formato de erro da API / tratamento na UI]
- **Logs:** [o que pode e o que nunca entra em log]
- **Datas, dinheiro, fuso:** [ex.: dinheiro em centavos inteiros; datas em UTC, exibição em America/Sao_Paulo]
- **Testes:** [ferramentas por camada]
- **Ambientes:** [dev / homologação / produção e como se chega em cada um]

## ADRs
| Nº | Título | Status |
|---|---|---|

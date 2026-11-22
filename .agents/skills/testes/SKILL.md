---
name: testes
description: Padrões de teste - nomes com ID do CT, caminho de produção, prova do efeito, isolamento por tenant, concorrência, regras do Firebase no emulador, testes de tela e mobile. Use ao escrever ou revisar testes.
---

# Testes

## Princípios
- Os testes nascem dos CT da spec. Cada CT tem ao menos um teste com o ID no início do nome: `it("CT-04: recusa pedido duplicado", ...)`.
- Regra de negócio e bug: teste primeiro, falhando pelo motivo certo.
- O teste confere o que a coluna **"Prova"** pede. Se a prova parecer impossível ou errada, pare e pergunte; não troque por uma verificação mais fácil.
- CT novo descoberto na implementação: acrescente na spec e no plano no mesmo commit.
- Dados de teste fictícios (`@exemplo.com.br`, nomes inventados). Nunca dado real.
- Dinheiro em inteiro (centavos) ou decimal com escala; nunca comparar `float`.

## Caminho de produção (o defeito mais caro é o teste verde com o recurso quebrado)
- **Entrada pela mesma porta da produção:** requisição HTTP (supertest/MockMvc/httpx) com autenticação real de teste; chamada da Cloud Function pelo wrapper/emulador; ação do usuário na tela (Testing Library). Nunca chamar o repositório direto para *executar* a ação testada.
- **Sem atalho de persistência na ação testada.** Acesso direto ao banco serve para montar dados e para *ler* o resultado.
- **Confira o efeito, não só o retorno:** o documento/linha gravado, o evento emitido, a mensagem exibida, o e-mail enfileirado.
- **Rotinas sem requisição** (job, webhook, trigger): ao menos um teste pelo mesmo ponto de entrada da produção.
- **Concorrência** (saldo, estoque, sequência, "só um pode"): um teste com duas execuções simultâneas contra o banco real/emulador (transação ou incremento atômico).
- **Log:** prove ausência de dado sensível capturando a saída real.

## Isolamento (obrigatório para acesso por ID)
Para cada endpoint/consulta/regra que recebe ID: usuário do tenant A tentando ler/alterar recurso do tenant B → 404 (ou negado pela regra), e o item não aparece em listagens, buscas e exportações.

## Por tipo
| Tipo | Ferramenta típica | Quando |
|---|---|---|
| Regra pura | Vitest/Jest/JUnit/pytest, sem framework | Toda regra de negócio e borda |
| Integração/API | supertest, MockMvc, httpx + banco real em container (Testcontainers) ou emulador | Casos de uso com persistência e permissão |
| Regras do Firebase | `@firebase/rules-unit-testing` no emulador | Toda coleção/caminho de Storage novo ou alterado: dono pode, outro não pode, anônimo não pode, campo proibido recusado |
| Cloud Functions | `firebase-functions-test` + emulador | Gatilhos e callables |
| Tela web | Testing Library + MSW para a API | Fluxo, estados, mensagens, acessibilidade básica (roles e labels) |
| Mobile | Jest + React Native Testing Library; Maestro para fluxo crítico | Telas e navegação |
| Ponta a ponta | Playwright (web) / Maestro (mobile) | Só fluxos críticos (login, compra, operação central) |

Banco de teste é do mesmo tipo da produção (Postgres em container, emulador do Firestore). Nada de banco em memória que se comporta diferente.

## Testes de referência
Casos com valor esperado vindo de fonte externa (planilha do cliente, sistema legado, contador) ficam numa pasta listada em `.agents/protegidos.txt` e só o responsável altera. Divergência: reporte caso, esperado, calculado e fonte.

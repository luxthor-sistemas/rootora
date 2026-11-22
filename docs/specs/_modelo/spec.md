# NNN — [Nome da feature]

- **Status:** rascunho | aprovada | em implementação | concluída
- **Trilha:** padrão | crítica
- **Tela:** sim (ver `prototipo.html`) | não
- **Data:** AAAA-MM-DD

> Spec autossuficiente: quem implementa não tem acesso à conversa do chat nem aos documentos do cliente. Tudo que importa está aqui. Seções que não se aplicam: escreva "Não se aplica." em vez de apagar.

## 1. Objetivo
[3 a 5 linhas: problema, para quem, resultado esperado.]

## 2. Escopo
**Inclui:**
- [item]

**Não inclui:**
- [item — evita scope creep]

## 3. Regras de negócio
| ID | Regra | Fonte |
|---|---|---|
| RN-01 | [regra objetiva, com valores e limites] | [cliente / lei / ADR-NNNN / decisão do responsável em AAAA-MM-DD] |

## 4. Estados e transições
[Se há entidade com estado (pedido, assinatura, aprovação): todas as transições e a regra que dispara cada uma. Senão: "Sem estado."]

| De | Para | Quando | Regra |
|---|---|---|---|

## 5. Dados e contratos
[Entidades/coleções e campos (tipo, obrigatório, limite). Endpoints, Cloud Functions ou eventos: verbo, caminho, entrada, saída, códigos de erro. Só o que é contrato; detalhe interno fica para quem implementa.]

## 6. Permissões e dados sensíveis
- **Quem pode fazer o quê:** [papel → ação]
- **Isolamento:** [por tenant/dono; onde é filtrado]
- **Dados pessoais/sensíveis:** [quais; o que nunca vai para log ou para a resposta]

**Ameaças** (obrigatório na trilha crítica ou com dado pessoal/endpoint com ID; senão "Não se aplica."):

| Ameaça | Controle (RN, CA ou "padrão: SEG-xx") |
|---|---|
| Usuário acessa registro de outro tenant por ID | padrão: SEG-10 |
| Duas execuções simultâneas | |
| O que vai para banco/log | |
| O que a resposta ou o erro revelam | |

## 7. Telas
[Se tem tela: lista de telas, campos, ações, mensagens exibidas e estados (carregando, vazio, erro, sucesso, sem permissão). Referência visual: `prototipo.html`. Em divergência, vale esta spec. Senão: "Sem tela."]

| Tela | Campos e ações | Estados | CA |
|---|---|---|---|

## 8. Critérios de aceite
- **CA-01 (fluxo principal):** Dado [contexto], quando [ação], então [resultado observável]. (RN-01)
- **CA-02 (erro):** Dado [condição], quando [ação], então a mensagem "[texto exato exibido]" aparece e [nada é gravado]. (RN-0x)

## 9. Cenários de teste
"Prova" diz por onde o teste entra e o que confere. Teste de integração entra pelo caminho de produção (requisição HTTP, chamada da função, ação na tela) e confere o efeito (banco, resposta, tela), não só o retorno.

| CT | CA | Cenário (inclui bordas: vazio, limite, duplicado, sem permissão, outro tenant, concorrência) | Prova |
|---|---|---|---|
| CT-01 | CA-01 | [cenário] | [ex.: POST /pedidos com sessão real → 201 e linha no banco com status "aberto"] |

## 10. Decisões do esclarecimento
| Pergunta | Decisão | Fonte |
|---|---|---|

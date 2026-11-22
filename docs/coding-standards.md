# Padrões de Engenharia

Regras transversais de qualidade. Segurança detalhada na skill `seguranca`; testes na skill `testes`; específico de stack nas skills `stack-*`.

## Separação de responsabilidades
- **UI** renderiza, captura eventos e formata exibição. Sem regra de negócio crítica, sem chamada direta ao banco espalhada por componentes: use uma camada de dados/hooks.
- **Regra de negócio** em funções/serviços testáveis sem framework (casos de uso, domínio). Toda regra exibida na UI é garantida no servidor.
- **Persistência** encapsulada (repositórios, adaptadores, módulo de acesso ao Firestore). Operações que mexem em várias entidades relacionadas são atômicas (transação/batch).
- **Entrada fina:** controllers, handlers e Cloud Functions autenticam, validam o formato, chamam o caso de uso e mapeiam a resposta.

## Configuração
- Config sensível vem de variável de ambiente ou gerenciador de segredos; `.env` nunca é versionado, só `.env.example` com valores fictícios.
- Falhe na inicialização se faltar variável obrigatória.

## Código
- Nomes alinhados ao `docs/glossario.md`. Um conceito, um nome.
- Erros explícitos e previsíveis; nunca `catch` vazio.
- Antes de criar utilitário, filtro ou tratamento de erro, procure se já existe.
- Sem código morto, sem comentário que repete o código. Comente o porquê, não o quê.
- Dependência nova: justificar (o que resolve, tamanho, manutenção, licença).

## Testes
- Regra de negócio: teste unitário. Fluxo com persistência, permissão e erro: teste de integração pelo caminho de produção.
- Operações sujeitas a reenvio (webhook, pagamento, fila): idempotentes, com teste.

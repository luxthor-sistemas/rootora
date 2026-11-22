---
name: seguranca
description: Checklist de segurança (OWASP ASVS nível 2 e API Top 10, LGPD) para web, SaaS multi-tenant, Firebase e React Native - autenticação, autorização, isolamento por tenant, entrada, segredos, logs e dados pessoais. Use ao especificar, implementar ou revisar endpoints, regras de acesso, dados sensíveis e integrações.
---

# Segurança

Use os mecanismos prontos da plataforma (provedor de autenticação, Firebase Auth, bibliotecas consolidadas). **Nenhuma criptografia própria.**

**Destino de cada item na spec** (cite pelo ID):
- `[decisão]` — a spec decide o valor/comportamento para esta feature. Vira regra (RN) com fonte; sem resposta na documentação, é pergunta na entrevista.
- `[CA]` — comportamento que precisa de teste específico. Vira CA com CT e "Prova" quando a feature o toca.
- `[padrão]` — aplicado sempre que se aplica, sem CT na spec. Na tabela de ameaças, cite "padrão: SEG-xx".

## Autenticação e sessão
- **SEG-01** `[padrão]` Autenticação pelo provedor (Firebase Auth, Auth0, Cognito, Supabase, ou biblioteca consolidada). Senha própria só com Argon2id/bcrypt; mínimo 8, aceita 64+; sem regras de composição.
- **SEG-02** `[padrão]` Mensagem genérica no login ("e-mail ou senha inválidos"); recuperação de senha não revela se o e-mail existe.
- **SEG-03** `[decisão]` Limite de tentativas e atraso progressivo (login, recuperação, códigos).
- **SEG-04** `[decisão]` Expiração de sessão (inatividade e absoluta) e o que encerra todas as sessões (troca de senha, desligamento).
- **SEG-05** `[padrão]` Web com backend próprio: sessão em cookie `HttpOnly`, `Secure`, `SameSite=Lax` e CSRF; sem token em `localStorage`. SPA com Firebase: SDK oficial, token nunca copiado para storage próprio.
- **SEG-06** `[padrão]` Mobile: token/credencial só em armazenamento seguro (Keychain/Keystore via `expo-secure-store` ou equivalente), nunca em `AsyncStorage`.
- **SEG-07** `[decisão]` MFA: se e para quem.
- **SEG-08** `[decisão]` Eventos de autenticação e ações sensíveis auditados (quem, quando, o quê, de onde).

## Autorização e isolamento
- **SEG-09** `[decisão]` Qual papel/permissão cada ação exige.
- **SEG-10** `[padrão]` **BOLA:** todo acesso por ID confere se o recurso pertence ao tenant/dono do usuário, no filtro da consulta (ou na regra do Firebase), nunca só depois de buscar. Vale para listagem, exportação e relatório.
- **SEG-11** `[padrão]` Tenant e papel vêm da sessão/token verificado (custom claims ou registro no servidor), nunca do corpo da requisição.
- **SEG-12** `[padrão]` **Atribuição em massa:** DTO/whitelist de campos por operação; campos como papel, tenant, preço, status, saldo nunca vêm do cliente sem regra.
- **SEG-13** `[decisão]` **Exposição:** a resposta só leva o que o usuário pode ver; dados sensíveis exigem permissão própria.
- **SEG-14** `[padrão]` Firebase: regras de Firestore/Storage negam por padrão; cada coleção com regra explícita de leitura e escrita por dono/tenant e validação de campos e tipos; nada de `allow read, write: if request.auth != null` genérico. Regras testadas no emulador.
- **SEG-15** `[decisão]` Ator de sistema (job, webhook, Cloud Function agendada): quem é, o que pode, como é registrado. Ponto de entrada próprio, sem passar por cima da verificação de permissão de usuário.
- **SEG-16** `[CA]` Ações destrutivas ou financeiras: confirmação, idempotência e trilha de auditoria.

## Entrada, injeção e integrações
- **SEG-17** `[padrão]` Validação de esquema (Zod, class-validator, Bean Validation, Pydantic) em todo payload, query, params, header e webhook, com limites de tamanho.
- **SEG-18** `[padrão]` Consultas parametrizadas; nunca concatenar entrada em SQL/NoSQL, comando de SO, caminho de arquivo ou nome de coluna/ordenação sem lista permitida.
- **SEG-19** `[padrão]` Saída escapada; HTML do usuário só com sanitizador (`dangerouslySetInnerHTML` proibido sem ele).
- **SEG-20** `[padrão]` Webhooks: assinatura verificada, idempotência por ID do evento, resposta rápida e processamento assíncrono.
- **SEG-21** `[decisão]` Serviço externo fora do esperado (timeout, status ≠ 2xx, corpo inválido): comportamento definido na spec, nunca tratado como sucesso.
- **SEG-22** `[padrão]` Chamadas a URL vinda do usuário só para destinos permitidos (SSRF).
- **SEG-23** `[decisão]` Upload: tipos aceitos e tamanho máximo. `[padrão]` tipo conferido pelo conteúdo, armazenado fora do servidor web, nunca executado.
- **SEG-24** `[padrão]` Rate limiting em endpoints públicos e caros (login, cadastro, envio de e-mail/SMS, busca, IA).

## Dados, segredos e logs (LGPD)
- **SEG-25** `[padrão]` Segredos só em variável de ambiente/gerenciador de segredos; nada de chave de servidor no app web ou mobile (o bundle é público). Config pública do Firebase não é segredo; chaves de admin e de terceiros são.
- **SEG-26** `[padrão]` Logs sem senha, token, documento (CPF/CNPJ), dado bancário, saúde ou conteúdo sensível. Exceção logada também é log: registre classe, código e ID de correlação, não o objeto inteiro.
- **SEG-27** `[padrão]` Erro para o cliente sem stack trace nem detalhe interno.
- **SEG-28** `[decisão]` Dados pessoais: finalidade, retenção, exclusão a pedido do titular e quem pode exportar.
- **SEG-29** `[padrão]` Ambientes de teste/homologação sem dados pessoais reais nem credenciais de produção.

## Borda e cadeia de software
- **SEG-30** `[padrão]` HTTPS/HSTS, CSP restritiva, `X-Content-Type-Options`, `frame-ancestors 'none'`, CORS só para origens conhecidas.
- **SEG-31** `[padrão]` Dependência nova justificada, lockfile versionado, sem vulnerabilidade crítica conhecida.

#!/usr/bin/env bash
# PreToolUse (Claude Code e Codex): bloqueia ações perigosas antes de executarem.
# Saída 2 bloqueia a ação e devolve o motivo (stderr) ao agente.
# Entende o formato do Claude (Read/Edit/Write/MultiEdit/Bash) e do Codex (Bash/shell/exec_command/apply_patch).
# Requer: bash, jq, git.

input=$(cat)
command -v jq >/dev/null 2>&1 || { echo "guard.sh: jq não instalado; ação bloqueada por segurança." >&2; exit 2; }

tool=$(jq -r '.tool_name // ""' <<<"$input")
root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

bloquear() {
  echo "Bloqueado pelo guard do harness: $1" >&2
  exit 2
}

# ---------- Arquivos ----------
protegido() {
  # $1: caminho (absoluto ou relativo). Confere contra .agents/protegidos.txt.
  local rel="${1#"$root"/}" padrao
  [ -f "$root/.agents/protegidos.txt" ] || return 1
  shopt -s globstar extglob
  while IFS= read -r padrao; do
    padrao="${padrao%%#*}"; padrao="${padrao%"${padrao##*[![:space:]]}"}"
    [ -z "$padrao" ] && continue
    # shellcheck disable=SC2053
    [[ "$rel" == $padrao ]] && return 0
  done <"$root/.agents/protegidos.txt"
  return 1
}

checar_arquivo() {
  # $1: caminho; $2: "leitura" ou "escrita"
  local path="$1" modo="$2" base
  [ -z "$path" ] && return 0
  base=$(basename -- "$path")
  case "$base" in
    .env.example|.env.sample|.env.template) ;;
    .env|.env.*|*.env) bloquear "arquivos .env não podem ser lidos nem editados (use .env.example)." ;;
    *.pem|*.key|*.p12|*.pfx|*.jks|*.keystore|*.mobileprovision) bloquear "certificados e chaves não podem ser lidos nem editados." ;;
    *serviceAccount*.json|*service-account*.json|*-firebase-adminsdk-*.json) bloquear "credenciais de conta de serviço não podem ser lidas nem editadas." ;;
  esac
  case "$path" in
    */secrets/*|secrets/*) bloquear "pasta de segredos." ;;
  esac
  if [ "$modo" = "escrita" ] && protegido "$path"; then
    bloquear "'${path#"$root"/}' está em .agents/protegidos.txt. Se parecer errado, descreva a divergência ao responsável em vez de alterar."
  fi
}

case "$tool" in
  Read)
    checar_arquivo "$(jq -r '.tool_input.file_path // .tool_input.path // ""' <<<"$input")" leitura
    exit 0
    ;;
  Edit|Write|MultiEdit|NotebookEdit)
    checar_arquivo "$(jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // ""' <<<"$input")" escrita
    exit 0
    ;;
  apply_patch)
    patch=$(jq -r '.tool_input.patch // .tool_input.input // .tool_input.command // "" | if type=="array" then join("\n") else . end' <<<"$input")
    while IFS= read -r arq; do
      checar_arquivo "$arq" escrita
    done < <(sed -nE 's/^\*\*\* (Add|Update|Delete) File: (.*)$/\2/p; s/^\*\*\* Move to: (.*)$/\1/p' <<<"$patch")
    exit 0
    ;;
  Bash|shell|exec_command|local_shell) ;;
  *) exit 0 ;;
esac

# ---------- Shell ----------
cmd=$(jq -r '.tool_input.command // .tool_input.cmd // "" | if type=="array" then join(" ") else . end' <<<"$input")
[ -z "$cmd" ] && exit 0

# Infra como código: só plan/validate/fmt localmente.
if grep -Eq '(^|[;&|[:space:]])(tofu|terraform)([[:space:]][^;&|]*)?[[:space:]](apply|destroy|import)([[:space:]]|$)' <<<"$cmd" \
   || grep -Eq '(tofu|terraform)([[:space:]][^;&|]*)?[[:space:]]state[[:space:]]+(rm|mv|push|replace-provider)' <<<"$cmd"; then
  bloquear "apply, destroy, import e alteração de state só pela pipeline."
fi

# Deploy e publicação: responsável ou CI.
if grep -Eq '(^|[;&|[:space:]])firebase([[:space:]][^;&|]*)?[[:space:]](deploy|firestore:delete|database:(remove|set|update|push)|auth:import|hosting:disable)([[:space:]]|$)' <<<"$cmd"; then
  bloquear "deploy e operações destrutivas do Firebase são do responsável ou do CI (emuladores estão liberados)."
fi
if grep -Eq '(^|[;&|[:space:]])eas([[:space:]][^;&|]*)?[[:space:]]submit([[:space:]]|$)' <<<"$cmd"; then
  bloquear "envio para as lojas (eas submit) é do responsável ou do CI."
fi
if grep -Eq '(^|[;&|[:space:]])eas([[:space:]][^;&|]*)?[[:space:]]update([[:space:]]|$)' <<<"$cmd" \
   && grep -Eiq -- '--(branch|channel)[=[:space:]]+["'\'']?prod' <<<"$cmd"; then
  bloquear "update OTA em produção é do responsável ou do CI."
fi
if grep -Eq '(^|[;&|[:space:]])(npm|pnpm|yarn)[[:space:]]+publish([[:space:]]|$)' <<<"$cmd"; then
  bloquear "publicação de pacote é do responsável."
fi
if grep -Eq '(^|[;&|[:space:]])(vercel|netlify)([[:space:]][^;&|]*)?[[:space:]](--prod|deploy[[:space:]][^;&|]*--prod)' <<<"$cmd"; then
  bloquear "deploy em produção é do responsável ou do CI."
fi

# git push: sem força, sem --all/--mirror, nunca na branch principal.
push_re='git([[:space:]]+(-[cC][[:space:]]+[^[:space:]]+|--[^[:space:]]+))*[[:space:]]+push'
if grep -Eq "$push_re" <<<"$cmd"; then
  if grep -Eq '(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$)|[[:space:]]\+[^[:space:]]+)' <<<"$cmd"; then
    bloquear "push forçado não é permitido."
  fi
  if grep -Eq "${push_re}[^;&|]*[[:space:]]--(all|mirror)([[:space:]]|$)" <<<"$cmd"; then
    bloquear "push de todas as branches (--all, --mirror) não é permitido."
  fi
  while read -r trecho; do
    sem_aspas=${trecho//[\"\']/}
    read -ra args <<<"${sem_aspas#*push}"
    for arg in "${args[@]}"; do
      if [[ "$arg" =~ ^([^:]*:)?(refs/heads/)?(main|master)$ ]]; then
        bloquear "push direto na branch principal não é permitido; abra um PR."
      fi
    done
  done < <(grep -oE "${push_re}([[:space:]]+[^;&|[:space:]]+)*" <<<"$cmd")
  branch=$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ "$branch" == "main" || "$branch" == "master" ]]; then
    bloquear "a branch atual é a principal; crie uma branch antes do push."
  fi
fi

# Merge de PR: só o responsável.
if grep -Eq 'gh[[:space:]]+pr[[:space:]]+merge' <<<"$cmd" \
   || grep -Eq 'gh[[:space:]]+api([[:space:]].*)?pulls/[0-9]+/merge' <<<"$cmd" \
   || { grep -Eq 'gh[[:space:]]+api' <<<"$cmd" && grep -Eiq 'mergePullRequest|enablePullRequestAutoMerge' <<<"$cmd"; }; then
  bloquear "o agente não faz merge de PR; o merge é do responsável."
fi

# Cloud CLIs: só leitura.
if grep -Eq '(^|[;&|[:space:]])gcloud[[:space:]]' <<<"$cmd" \
   && grep -Eq '[[:space:]](deploy|delete|create|update|patch|import|restore|clone|set-iam-policy|add-iam-policy-binding|remove-iam-policy-binding)([[:space:]]|$)' <<<"$cmd"; then
  bloquear "gcloud só para leitura; recursos mudam pela pipeline."
fi
if grep -Eq '(^|[;&|[:space:]])aws[[:space:]]' <<<"$cmd" \
   && grep -Eq '[[:space:]](delete-[a-z-]+|terminate-[a-z-]+|rm|rb|put-[a-z-]+|create-[a-z-]+|update-[a-z-]+|deploy)([[:space:]]|$)' <<<"$cmd"; then
  bloquear "aws só para leitura; recursos mudam pela pipeline."
fi

# Banco: só local.
if grep -Eq '(^|[;&|[:space:]])(psql|pg_dump|pg_restore|mysql|mongosh|mongo)([[:space:]]|$)' <<<"$cmd"; then
  if grep -Eq '(-h[[:space:]]*|--host[=[:space:]]|host=|@)[^[:space:]]' <<<"$cmd" \
     && ! grep -Eq '(-h[[:space:]]*|--host[=[:space:]]|host=|@)(localhost|127\.0\.0\.1|db|postgres)([:/[:space:]]|$)' <<<"$cmd"; then
    bloquear "acesso a banco só no ambiente local."
  fi
fi

# Ler .env pelo shell.
if grep -Eq '(cat|less|more|head|tail|source|grep|rg|sed|awk|bat|cp|base64|xxd|strings)[[:space:]]+([^|;&]*[/[:space:]])?\.env([[:space:].]|$)' <<<"$cmd" \
   && ! grep -Eq '\.env\.(example|sample|template)' <<<"$cmd"; then
  bloquear "arquivos .env não podem ser lidos."
fi
if grep -Eq '(^|[;&|[:space:]])(printenv|env)([[:space:]]*($|[;&|]))' <<<"$cmd"; then
  bloquear "listar todas as variáveis de ambiente pode expor segredos; consulte só a variável necessária."
fi

# Remoção recursiva de raiz, home ou do projeto inteiro.
if grep -Eq 'rm[[:space:]]+(-[a-zA-Z]*[rR][a-zA-Z]*|--recursive)([[:space:]]+-[a-zA-Z]+)*[[:space:]]+("?(/|~|\$HOME|\.\.?|\*)"?/?)([[:space:]]|$)' <<<"$cmd"; then
  bloquear "remoção recursiva de diretório raiz, home ou do projeto inteiro."
fi

# Escrita por shell em arquivo protegido (prefixo literal de cada padrão).
if [ -f "$root/.agents/protegidos.txt" ] \
   && grep -Eq '(sed[[:space:]]+-i|>|[[:space:]](mv|rm|cp|tee|truncate)[[:space:]]|git[[:space:]]+(checkout|restore|rm)[[:space:]])' <<<"$cmd"; then
  while IFS= read -r padrao; do
    padrao="${padrao%%#*}"; padrao="${padrao%"${padrao##*[![:space:]]}"}"
    prefixo="${padrao%%[*?[]*}"
    [ ${#prefixo} -lt 4 ] && continue
    if grep -qF -- "$prefixo" <<<"$cmd"; then
      bloquear "comando altera '$prefixo', listado em .agents/protegidos.txt."
    fi
  done <"$root/.agents/protegidos.txt"
fi

exit 0

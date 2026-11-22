#!/usr/bin/env bash
# Testes do guard.sh com payloads do Claude Code e do Codex.
set -u
dir=$(cd "$(dirname "$0")/.." && pwd)
guard="$dir/guard.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q -b feat/x && git -C "$tmp" -c user.email=t@exemplo.com.br -c user.name=t commit -q --allow-empty -m init
mkdir -p "$tmp/.agents"; printf 'tests/referencia/**\n' >"$tmp/.agents/protegidos.txt"
export CLAUDE_PROJECT_DIR="$tmp"
falhas=0

caso() { # $1 esperado(0|2) $2 descrição $3 json
  local saida; echo "$3" | bash "$guard" >/dev/null 2>&1; saida=$?
  if [ "$saida" != "$1" ]; then echo "FALHOU: $2 (esperado $1, veio $saida)"; falhas=$((falhas+1)); fi
}
bash_() { printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(jq -Rn --arg c "$1" '$c')"; }
codex_shell() { printf '{"tool_name":"exec_command","tool_input":{"cmd":%s}}' "$(jq -Rn --arg c "$1" '$c')"; }
patch_() { printf '{"tool_name":"apply_patch","tool_input":{"command":%s}}' "$(jq -Rn --arg c "$1" '$c')"; }

caso 2 "ler .env (Claude)" '{"tool_name":"Read","tool_input":{"file_path":"/p/.env"}}'
caso 0 "ler .env.example" '{"tool_name":"Read","tool_input":{"file_path":"/p/.env.example"}}'
caso 2 "editar .env.local" '{"tool_name":"Edit","tool_input":{"file_path":"/p/.env.local"}}'
caso 2 "service account" '{"tool_name":"Read","tool_input":{"file_path":"/p/app-firebase-adminsdk-abc.json"}}'
caso 0 "editar código" '{"tool_name":"Write","tool_input":{"file_path":"/p/src/app.ts"}}'
caso 2 "editar protegido" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$tmp/tests/referencia/caso1.json\"}}"
caso 0 "ler protegido" "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$tmp/tests/referencia/caso1.json\"}}"
caso 2 "patch Codex em .env" "$(patch_ $'*** Begin Patch\n*** Update File: .env\n@@\n-A=1\n+A=2\n*** End Patch')"
caso 2 "patch Codex em protegido" "$(patch_ $'*** Begin Patch\n*** Add File: tests/referencia/novo.json\n+{}\n*** End Patch')"
caso 0 "patch Codex em código" "$(patch_ $'*** Begin Patch\n*** Update File: src/a.ts\n@@\n-1\n+2\n*** End Patch')"
caso 2 "cat .env" "$(bash_ 'cat .env')"
caso 2 "cat .env (Codex)" "$(codex_shell 'cat .env')"
caso 0 "cat .env.example" "$(bash_ 'cat .env.example')"
caso 2 "printenv" "$(bash_ 'printenv')"
caso 0 "echo var" "$(bash_ 'echo $NODE_ENV')"
caso 2 "push main" "$(bash_ 'git push origin main')"
caso 2 "push HEAD:main" "$(bash_ 'git push origin HEAD:main')"
caso 2 "push force" "$(bash_ 'git push -f origin feat/x')"
caso 2 "push --force-with-lease" "$(bash_ 'git push --force-with-lease')"
caso 0 "push branch" "$(bash_ 'git push -u origin feat/x')"
caso 2 "gh pr merge" "$(bash_ 'gh pr merge 12 --squash')"
caso 0 "gh pr create" "$(bash_ 'gh pr create --fill')"
caso 2 "firebase deploy" "$(bash_ 'npx firebase deploy --only functions')"
caso 0 "firebase emulators" "$(bash_ 'firebase emulators:exec "npm test"')"
caso 2 "eas submit" "$(bash_ 'eas submit -p ios')"
caso 2 "eas update prod" "$(bash_ 'eas update --branch production --message x')"
caso 0 "eas update preview" "$(bash_ 'eas update --branch preview --message x')"
caso 2 "tofu apply" "$(bash_ 'tofu -chdir=infra apply')"
caso 0 "tofu plan" "$(bash_ 'tofu -chdir=infra plan')"
caso 2 "gcloud deploy" "$(bash_ 'gcloud run deploy api')"
caso 0 "gcloud list" "$(bash_ 'gcloud run services list')"
caso 2 "psql remoto" "$(bash_ 'psql -h db.prod.exemplo.com -U app')"
caso 0 "psql local" "$(bash_ 'psql -h localhost -U app')"
caso 2 "rm -rf ." "$(bash_ 'rm -rf .')"
caso 2 "rm -rf ~" "$(bash_ 'rm -rf ~')"
caso 0 "rm -rf build" "$(bash_ 'rm -rf build dist')"
caso 2 "sed em protegido" "$(bash_ 'sed -i s/1/2/ tests/referencia/caso1.json')"
caso 0 "npm test" "$(bash_ 'npm test')"
caso 2 "npm publish" "$(bash_ 'npm publish')"

git -C "$tmp" checkout -q -b main 2>/dev/null
caso 2 "push estando na main" "$(bash_ 'git push')"

[ "$falhas" -eq 0 ] && echo "guard.test.sh: ok" || { echo "guard.test.sh: $falhas falha(s)"; exit 1; }

#!/usr/bin/env bash
# Testes do verificar.sh (hook Stop): libera sem mudança, bloqueia na falha, não repete o mesmo erro, cache de sucesso.
set -u
raiz=$(cd "$(dirname "$0")/../../.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cd "$tmp" || exit 1
git init -q -b feat/x
mkdir -p scripts/harness
cp "$raiz/scripts/harness/verificar.sh" scripts/harness/
printf '.harness/\n' >.gitignore
# check.local.sh controlado pelo teste: falha se existir o arquivo QUEBRADO
mkdir -p scripts && printf '#!/usr/bin/env bash\necho "rodou" >>.harness/execucoes\n[ ! -f QUEBRADO ]\n' >scripts/check.local.sh
cp "$raiz/scripts/harness/check.sh" scripts/harness/
git add -A && git -c user.email=t@exemplo.com.br -c user.name=t commit -qm init
export CLAUDE_PROJECT_DIR="$tmp"
falhas=0
stop() { echo '{"session_id":"s"}' | bash scripts/harness/verificar.sh >/dev/null 2>&1; echo $?; }
execucoes() { wc -l <.harness/execucoes 2>/dev/null || echo 0; }
esperar() { [ "$2" = "$3" ] || { echo "FALHOU: $1 (esperado $2, veio $3)"; falhas=$((falhas+1)); }; }

esperar "sem mudanças libera" 0 "$(stop)"
touch QUEBRADO
esperar "falha bloqueia" 2 "$(stop)"
antes=$(execucoes)
esperar "mesmo conteúdo com falha não bloqueia de novo" 1 "$(stop)"
esperar "mesmo conteúdo com falha não roda de novo" "$antes" "$(execucoes)"
rm QUEBRADO; echo ok >novo.txt
esperar "corrigido libera" 0 "$(stop)"
antes=$(execucoes)
esperar "mesmo conteúdo ok libera" 0 "$(stop)"
esperar "mesmo conteúdo ok não roda de novo" "$antes" "$(execucoes)"
HARNESS_SEM_VERIFICAR=1 esperar "desligado" 0 "$(touch QUEBRADO; HARNESS_SEM_VERIFICAR=1 stop)"

[ "$falhas" -eq 0 ] && echo "verificar.test.sh: ok" || { echo "verificar.test.sh: $falhas falha(s)"; exit 1; }

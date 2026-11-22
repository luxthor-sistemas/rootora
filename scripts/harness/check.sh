#!/usr/bin/env bash
# Verificação do projeto, independente de stack. Devolve só o essencial; log completo em .harness/ultimo-check.log.
#   bash scripts/harness/check.sh                 rápido, projeto inteiro
#   bash scripts/harness/check.sh completo        inclui build (antes do PR)
#   bash scripts/harness/check.sh rapido a.ts b/  só os pacotes que contêm esses arquivos
# Convenção Node: se o package.json tiver o script "check" (rápido) ou "check:full" (completo), só ele roda;
# senão roda os que existirem entre typecheck, lint, test (e build no completo).
# Projeto com necessidade própria: crie scripts/check.local.sh (recebe os mesmos argumentos).
# Os arquivos alterados ficam em HARNESS_ARQUIVOS (caminhos absolutos, separados por espaço) para o script "check" do projeto
# rodar só os testes relacionados, ex.: "check": "tsc --noEmit && eslint . && vitest related --run $HARNESS_ARQUIVOS".
# Saída: 0 ok | 1 falhou.

set -u
root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$root" || exit 1

if [ -f scripts/check.local.sh ]; then
  exec bash scripts/check.local.sh "$@"
fi

modo="rapido"
case "${1:-}" in rapido|completo) modo="$1"; shift ;; esac
arquivos=("$@")
abs=()
for f in "${arquivos[@]}"; do abs+=("$root/${f#./}"); done
export HARNESS_ARQUIVOS="${abs[*]}"   # caminhos absolutos: funcionam de dentro de qualquer pacote

mkdir -p .harness
log=".harness/ultimo-check.log"
: >"$log"
falhou=0
resumo=()
falhas_log=()

rodar() {
  # $1: rótulo; resto: comando. Guarda a saída de cada passo separada para mostrar só a dos que falharam.
  local rotulo="$1"; shift
  local passo; passo=$(mktemp)
  local ok=0
  "$@" >"$passo" 2>&1 || ok=1
  { echo "===== $rotulo: $*"; cat "$passo"; } >>"$log"
  if [ "$ok" -eq 0 ]; then
    resumo+=("ok    $rotulo")
    rm -f "$passo"
  else
    resumo+=("FALHA $rotulo")
    falhou=1
    falhas_log+=("$rotulo|$passo")
  fi
}

toca() {
  # $1: diretório. Verdadeiro se não há filtro de arquivos ou se algum arquivo está dentro dele.
  local dir="$1" f
  [ ${#arquivos[@]} -eq 0 ] && return 0
  for f in "${arquivos[@]}"; do
    f="${f#./}"
    if [ "$dir" = "." ]; then
      # Na raiz: só se o arquivo não pertence a um subpacote
      local sub; sub=$(dirname "$f")
      while [ "$sub" != "." ] && [ "$sub" != "/" ]; do
        [ -f "$sub/package.json" ] && continue 2
        sub=$(dirname "$sub")
      done
      return 0
    fi
    case "$f" in "$dir"/*) return 0 ;; esac
  done
  return 1
}

# ---------- Node (web, Firebase Functions, React Native) ----------
mapfile -t pacotes < <(find . -maxdepth 3 -name package.json -not -path '*/node_modules/*' -printf '%h\n' 2>/dev/null | sed 's#^\./##' | sort)
for dir in "${pacotes[@]}"; do
  [ -z "$dir" ] && dir="."
  toca "$dir" || continue
  pj="$dir/package.json"
  # Pacote raiz de monorepo sem scripts úteis é pulado naturalmente.
  if   [ -f "$dir/pnpm-lock.yaml" ] || [ -f pnpm-lock.yaml ]; then pm=pnpm
  elif [ -f "$dir/yarn.lock" ] || [ -f yarn.lock ]; then pm=yarn
  elif [ -f "$dir/bun.lockb" ] || [ -f "$dir/bun.lock" ]; then pm=bun
  else pm=npm; fi
  command -v "$pm" >/dev/null 2>&1 || { resumo+=("aviso $dir: $pm não instalado; pulado"); continue; }
  if [ ! -d "$dir/node_modules" ] && [ ! -d node_modules ]; then
    resumo+=("aviso $dir: dependências não instaladas ($pm install); pulado"); continue
  fi
  scripts=$(jq -r '.scripts // {} | keys[]' "$pj" 2>/dev/null)
  tem() { grep -qx "$1" <<<"$scripts"; }
  if [ "$modo" = "rapido" ] && tem check; then
    rodar "$dir check" env -C "$dir" CI=true "$pm" run check
  elif [ "$modo" = "completo" ] && tem "check:full"; then
    rodar "$dir check:full" env -C "$dir" CI=true "$pm" run check:full
  else
    passos=(typecheck lint test)
    [ "$modo" = "completo" ] && passos+=(build)
    for s in "${passos[@]}"; do
      tem "$s" && rodar "$dir $s" env -C "$dir" CI=true "$pm" run "$s"
    done
  fi
done

# ---------- Gradle (Java/Kotlin) ----------
if [ -x ./gradlew ] && { [ ${#arquivos[@]} -eq 0 ] || printf '%s\n' "${arquivos[@]}" | grep -Eq '\.(java|kt|kts|gradle)$|(^|/)src/'; }; then
  if [ "$modo" = "completo" ]; then rodar "gradle build" ./gradlew -q build; else rodar "gradle test" ./gradlew -q test; fi
fi

# ---------- Python ----------
if [ -f pyproject.toml ] && { [ ${#arquivos[@]} -eq 0 ] || printf '%s\n' "${arquivos[@]}" | grep -q '\.py$'; }; then
  command -v ruff >/dev/null 2>&1 && rodar "ruff" ruff check .
  command -v pytest >/dev/null 2>&1 && rodar "pytest" pytest -q -x
fi

# ---------- Specs ----------
mapfile -t specs < <(printf '%s\n' "${arquivos[@]}" | grep -oE '^docs/specs/[^/_][^/]*' | sort -u)
for s in "${specs[@]}"; do
  [ -n "$s" ] && [ -d "$s" ] && rodar "spec $s" python3 scripts/harness/verificar_spec.py "$s"
done

[ ${#resumo[@]} -eq 0 ] && resumo+=("nada a verificar para estes arquivos")
printf '%s\n' "${resumo[@]}"
if [ "$falhou" -eq 1 ]; then
  # Só a saída dos passos que falharam, com limite por passo (economia de contexto).
  limite=$(( 70 / ${#falhas_log[@]} )); [ "$limite" -lt 15 ] && limite=15
  for item in "${falhas_log[@]}"; do
    rotulo="${item%%|*}"; arq="${item#*|}"
    echo "--- $rotulo (últimas linhas; completo em $log) ---"
    grep -vE '^[[:space:]]*$|^> |^\$ ' "$arq" | tail -n "$limite"
    rm -f "$arq"
  done
fi
exit "$falhou"

#!/usr/bin/env bash
# Classifica a mudança da branch atual: trilha=nenhuma | padrao | critica, seguida dos arquivos alterados.
# Base: merge-base com origin/main (ou main/master local). Inclui mudanças não commitadas.
root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$root" || exit 1

base=""
for ref in origin/main origin/master main master; do
  if git rev-parse -q --verify "$ref" >/dev/null 2>&1; then
    base=$(git merge-base "$ref" HEAD 2>/dev/null) && break
  fi
done

arquivos=$({
  [ -n "$base" ] && git diff --name-only "$base"...HEAD 2>/dev/null
  git diff --name-only HEAD 2>/dev/null
  git ls-files --others --exclude-standard 2>/dev/null
} | sort -u | grep -v -e '^$' -e '^\.harness/')

if [ -z "$arquivos" ]; then
  echo "trilha=nenhuma"
  exit 0
fi

trilha=padrao
criticos=""
if [ -f .agents/trilha-critica.txt ]; then
  padroes=$(grep -vE '^[[:space:]]*(#|$)' .agents/trilha-critica.txt)
  if [ -n "$padroes" ]; then
    criticos=$(grep -E -f <(echo "$padroes") <<<"$arquivos" || true)
    [ -n "$criticos" ] && trilha=critica
  fi
fi

echo "trilha=$trilha"
echo "base=${base:-nenhuma}"
[ -n "$criticos" ] && { echo "arquivos críticos:"; sed 's/^/  /' <<<"$criticos" | head -n 30; }
echo "arquivos alterados ($(wc -l <<<"$arquivos")):"
sed 's/^/  /' <<<"$arquivos" | head -n 200

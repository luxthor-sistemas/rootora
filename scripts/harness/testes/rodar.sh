#!/usr/bin/env bash
# Roda todos os testes do harness no projeto instalado (local e CI). Confere só o que pertence ao alvo
# escolhido na instalação (.agents/harness.toml: claude, codex ou ambos).
set -u
dir=$(cd "$(dirname "$0")" && pwd)
raiz=$(cd "$dir/../../.." && pwd)
falhou=0
erro() { echo "ERRO: $*"; falhou=1; }

alvo=$(sed -nE 's/^alvo[[:space:]]*=[[:space:]]*"([a-z]+)".*/\1/p' "$raiz/.agents/harness.toml" 2>/dev/null)
alvo=${alvo:-ambos}
claude=0; codex=0
case "$alvo" in claude) claude=1 ;; codex) codex=1 ;; ambos) claude=1; codex=1 ;; *) erro "alvo '$alvo' inválido em .agents/harness.toml" ;; esac
echo "alvo: $alvo"

for t in "$dir"/*.test.sh; do bash "$t" || falhou=1; done
python3 "$raiz/scripts/harness/gerar_agentes.py" --check || falhou=1

# Arquivo de regras e skills de cada ferramenta
if [ "$claude" -eq 1 ]; then
  [ -f "$raiz/CLAUDE.md" ] || erro "falta CLAUDE.md"
  jq empty "$raiz/.claude/settings.json" 2>/dev/null || erro ".claude/settings.json ausente ou inválido"
  [ -f "$raiz/.claude/skills/implementar/SKILL.md" ] || erro ".claude/skills não tem as skills (reinstale)"
fi
if [ "$codex" -eq 1 ]; then
  [ -f "$raiz/AGENTS.md" ] || erro "falta AGENTS.md"
  jq empty "$raiz/.codex/hooks.json" 2>/dev/null || erro ".codex/hooks.json ausente ou inválido"
  [ -f "$raiz/.agents/skills/implementar/SKILL.md" ] || erro ".agents/skills não tem as skills (reinstale)"
  python3 -c "import tomllib,sys; [tomllib.load(open(f,'rb')) for f in sys.argv[1:]]" \
    "$raiz/.codex/config.toml" "$raiz"/.codex/agents/*.toml || erro "TOML inválido em .codex/"
fi
# Exclusividade: nada da outra ferramenta
if [ "$alvo" = "claude" ]; then
  for x in AGENTS.md .codex .agents/skills; do [ -e "$raiz/$x" ] && erro "instalação só Claude Code, mas existe $x"; done
  grep -rqs 'AGENTS\.md' "$raiz/CLAUDE.md" "$raiz/.claude/skills" "$raiz/.claude/agents" && erro "referência a AGENTS.md numa instalação só Claude Code"
fi
if [ "$alvo" = "codex" ]; then
  for x in CLAUDE.md .claude; do [ -e "$raiz/$x" ] && erro "instalação só Codex, mas existe $x"; done
fi

# Skills: name igual à pasta e description presente
skills="$raiz/.agents/skills"; [ "$alvo" = "claude" ] && skills="$raiz/.claude/skills"
for s in "$skills"/*/SKILL.md; do
  nome=$(basename "$(dirname "$s")")
  grep -q "^name: $nome$" "$s" || erro "skill sem name igual à pasta: $s"
  grep -q "^description: ." "$s" || erro "skill sem description: $s"
done

if command -v shellcheck >/dev/null 2>&1; then
  extras=(); [ -f "$raiz/.claude/statusline.sh" ] && extras+=("$raiz/.claude/statusline.sh")
  shellcheck -S warning "$raiz"/scripts/harness/*.sh "$raiz"/scripts/harness/testes/*.sh "${extras[@]}" || falhou=1
fi
[ "$falhou" -eq 0 ] && echo "harness: todos os testes passaram" || echo "harness: há falhas"
exit "$falhou"

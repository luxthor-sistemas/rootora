#!/usr/bin/env bash
# Testes do gerador de agentes: mapeamento por nível, sobrescrita local e esforço inválido.
set -u
raiz=$(cd "$(dirname "$0")/../../.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/scripts/harness" "$tmp/.agents/agents"
cp "$raiz/scripts/harness/gerar_agentes.py" "$tmp/scripts/harness/"
cp "$raiz/.agents/modelos.toml" "$tmp/.agents/"
cat >"$tmp/.agents/agents/teste.md" <<'MD'
---
name: teste
description: agente de teste
nivel: forte
---
Corpo.
MD
falhas=0
gerar() { python3 "$tmp/scripts/harness/gerar_agentes.py" >/dev/null 2>&1; }

gerar || { echo "FALHOU: geração básica"; falhas=$((falhas+1)); }
grep -q '^model = "gpt-6.2-sol"$' "$tmp/.codex/agents/teste.toml" || { echo "FALHOU: modelo do nível no Codex"; falhas=$((falhas+1)); }
grep -q '^model: opus$' "$tmp/.claude/agents/teste.md" || { echo "FALHOU: modelo do nível no Claude"; falhas=$((falhas+1)); }

printf '[forte]\ncodex = { model = "gpt-local" }\n' >"$tmp/.agents/modelos.local.toml"
gerar
grep -q '^model = "gpt-local"$' "$tmp/.codex/agents/teste.toml" || { echo "FALHOU: sobrescrita local do modelo"; falhas=$((falhas+1)); }
grep -q '^model_reasoning_effort = "high"$' "$tmp/.codex/agents/teste.toml" || { echo "FALHOU: sobrescrita local apagou o esforço"; falhas=$((falhas+1)); }
rm "$tmp/.agents/modelos.local.toml"

sed -i 's/^nivel: forte$/nivel: forte\ncodex_effort: xhigh\nclaude_effort: low/' "$tmp/.agents/agents/teste.md"
gerar
grep -q '^model_reasoning_effort = "xhigh"$' "$tmp/.codex/agents/teste.toml" || { echo "FALHOU: codex_effort no frontmatter"; falhas=$((falhas+1)); }
grep -q '^effort: low$' "$tmp/.claude/agents/teste.md" || { echo "FALHOU: claude_effort no frontmatter"; falhas=$((falhas+1)); }

sed -i 's/^claude_effort: low$/claude_effort: xhigh/' "$tmp/.agents/agents/teste.md"
if gerar; then echo "FALHOU: aceitou esforço xhigh no Claude"; falhas=$((falhas+1)); fi

[ "$falhas" -eq 0 ] && echo "modelos.test.sh: ok" || { echo "modelos.test.sh: $falhas falha(s)"; exit 1; }

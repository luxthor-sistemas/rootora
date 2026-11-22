#!/usr/bin/env bash
# Stop (Claude Code e Codex): verifica o que mudou antes de o agente concluir o turno.
# - Sem mudanças, ou o mesmo conteúdo já passou: libera na hora (não roda nada).
# - O mesmo conteúdo já falhou e foi avisado: não roda de novo; avisa sem bloquear (o agente já viu o erro
#   e parou sem mexer — a decisão passa a ser do responsável).
# - Conteúdo novo: roda check.sh rápido só nos pacotes tocados. Falha bloqueia (saída 2) até 3 vezes por
#   sessão; depois disso continua avisando, sem bloquear, para não entrar em laço.
# Não é registrado em SubagentStop de propósito: subagentes só de leitura (qa, explorador) seriam
# bloqueados por mudanças da sessão principal que não podem corrigir. O dev roda o check pela skill.
# Desligar temporariamente: HARNESS_SEM_VERIFICAR=1.

[ "${HARNESS_SEM_VERIFICAR:-0}" = "1" ] && exit 0
input=$(cat)
sessao=$(jq -r '.session_id // "sem-sessao"' <<<"$input" 2>/dev/null || echo sem-sessao)

root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -z "$root" ] && exit 0
cd "$root" || exit 0

cache="$root/.harness/cache"
mkdir -p "$cache"

mudados=$({ git diff --name-only HEAD 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null; } | grep -v '^\.harness/' | sort -u)
[ -z "$mudados" ] && exit 0

estado=$({ echo "$mudados"; git diff HEAD -- . ':!.harness' 2>/dev/null; git ls-files --others --exclude-standard -z -- . ':!.harness' 2>/dev/null | xargs -0 -r cat 2>/dev/null; } | sha1sum | cut -d' ' -f1)
[ -f "$cache/ok-$estado" ] && exit 0
if [ -f "$cache/falha-$estado" ]; then
  echo "check.sh continua falhando (mesmo conteúdo já avisado). Não declare pronto; detalhes em .harness/ultimo-check.log." >&2
  exit 1
fi

tentativas_arq="$cache/tentativas-$sessao"
tentativas=$(cat "$tentativas_arq" 2>/dev/null || echo 0)

mapfile -t lista <<<"$mudados"
if saida=$(bash scripts/harness/check.sh rapido "${lista[@]}" 2>&1); then
  rm -f "$tentativas_arq"
  touch "$cache/ok-$estado"
  find "$cache" -type f -mtime +7 -delete 2>/dev/null
  exit 0
fi

touch "$cache/falha-$estado"
tentativas=$((tentativas + 1))
echo "$tentativas" >"$tentativas_arq"
if [ "$tentativas" -gt 3 ]; then
  { echo "check.sh ainda falha (já foram 3 tentativas nesta sessão). Não declare pronto:"; echo "$saida" | tail -n 30; } >&2
  exit 1
fi
{
  echo "Verificação falhou (tentativa $tentativas de 3). Corrija antes de concluir:"
  echo "$saida" | tail -n 70
} >&2
exit 2

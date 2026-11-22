#!/usr/bin/env bash
# Testes do verificar_spec.py: o modelo cru tem de falhar; uma spec completa tem de passar.
set -u
dir=$(cd "$(dirname "$0")/.." && pwd)
raiz=$(cd "$dir/../.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
falhas=0

cp -r "$raiz/docs/specs/_modelo" "$tmp/modelo"
if python3 "$dir/verificar_spec.py" "$tmp/modelo" >/dev/null 2>&1; then echo "FALHOU: modelo cru passou"; falhas=$((falhas+1)); fi

mkdir -p "$tmp/001-ok"
cat >"$tmp/001-ok/spec.md" <<'SPEC'
# 001 — Cadastro de tarefa
- **Status:** aprovada
- **Trilha:** padrão
- **Tela:** não
## 3. Regras de negócio
| ID | Regra | Fonte |
|---|---|---|
| RN-01 | Título obrigatório, até 120 caracteres | decisão do responsável em 2026-11-20 |
## 8. Critérios de aceite
- **CA-01 (fluxo principal):** Dado um usuário logado, quando cria tarefa com título, então ela aparece na lista. (RN-01)
- **CA-02 (erro):** Dado título vazio, quando salva, então aparece "Informe o título" e nada é gravado. (RN-01)
## 9. Cenários de teste
| CT | CA | Cenário | Prova |
|---|---|---|---|
| CT-01 | CA-01 | cria tarefa válida | chamada do caso de uso → documento gravado |
| CT-02 | CA-02 | título vazio | mensagem exibida e coleção vazia |
SPEC
python3 "$dir/verificar_spec.py" "$tmp/001-ok" >/dev/null 2>&1 || { echo "FALHOU: spec completa não passou"; python3 "$dir/verificar_spec.py" "$tmp/001-ok"; falhas=$((falhas+1)); }

cat >"$tmp/001-ok/plano.md" <<'PLANO'
# Plano — 001
### [ ] Fatia 01 · api — criar tarefa
- **Entrega:** CA-01
PLANO
if python3 "$dir/verificar_spec.py" "$tmp/001-ok" >/dev/null 2>&1; then echo "FALHOU: plano sem CA-02 passou"; falhas=$((falhas+1)); fi

sed -i 's/| CT-02 | CA-02 | título vazio | mensagem exibida e coleção vazia |/| CT-02 | CA-02 | título vazio | |/' "$tmp/001-ok/spec.md"
rm "$tmp/001-ok/plano.md"
if python3 "$dir/verificar_spec.py" "$tmp/001-ok" >/dev/null 2>&1; then echo "FALHOU: CT sem prova passou"; falhas=$((falhas+1)); fi

[ "$falhas" -eq 0 ] && echo "spec.test.sh: ok" || { echo "spec.test.sh: $falhas falha(s)"; exit 1; }

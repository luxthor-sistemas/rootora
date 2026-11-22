#!/usr/bin/env python3
"""Confere a coerência de uma spec (e do plano, se existir) antes de planejar, implementar ou revisar.

Uso:
  python3 scripts/harness/verificar_spec.py docs/specs/001-login   # uma feature
  python3 scripts/harness/verificar_spec.py                        # todas (menos _modelo)

Falha (saída 1) se encontrar: placeholder ou dúvida em aberto, RN sem fonte, CA sem CT, CT apontando
para CA inexistente, CT sem prova, tela sem protótipo, CA da spec ausente do plano.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
PLACEHOLDER = re.compile(
    r"\bTBD\b|\bTODO\b|\ba definir\b|\[PREENCHER|AAAA-MM-DD|\bNNN\b|\[regra objetiva|\[cenário\]|\[título\]",
    re.IGNORECASE,
)
ID_CA = re.compile(r"\*\*(CA-\d+)")
LINHA_RN = re.compile(r"^\|\s*(RN-\d+)\s*\|([^|]*)\|([^|]*)\|", re.M)
LINHA_CT = re.compile(r"^\|\s*(CT-\d+)\s*\|([^|]*)\|([^|]*)\|([^|]*)\|", re.M)
VAZIO = re.compile(r"^\s*(\[.*\])?\s*$")


def secao(texto: str, titulo_regex: str) -> str:
    m = re.search(rf"^##\s+\d*\.?\s*{titulo_regex}.*?$(.*?)(?=^##\s|\Z)", texto, re.M | re.S | re.I)
    return m.group(1) if m else ""


def conferir(pasta: Path) -> list[str]:
    erros: list[str] = []
    spec_p = pasta / "spec.md"
    if not spec_p.exists():
        return [f"{pasta}: falta spec.md"]
    spec = spec_p.read_text(encoding="utf-8")

    for n, linha in enumerate(spec.splitlines(), 1):
        if PLACEHOLDER.search(linha):
            erros.append(f"spec.md:{n}: placeholder ou pendência: {linha.strip()[:90]}")
    if re.search(r"^##.*d[úu]vidas em aberto", spec, re.M | re.I):
        corpo = secao(spec, r"d[úu]vidas em aberto")
        if corpo.strip() and not re.fullmatch(r"\s*(nenhuma\.?|-)\s*", corpo, re.I):
            erros.append("spec.md: seção 'Dúvidas em aberto' não está vazia")

    for rn, _regra, fonte in LINHA_RN.findall(spec):
        if VAZIO.match(fonte):
            erros.append(f"spec.md: {rn} sem fonte")

    cas = sorted(set(ID_CA.findall(spec)))
    if not cas:
        erros.append("spec.md: nenhum critério de aceite (**CA-01 ...**)")
    cts = LINHA_CT.findall(spec)
    if not cts:
        erros.append("spec.md: nenhum cenário de teste (linha | CT-01 | CA-01 | ... | prova |)")
    cobertos: set[str] = set()
    for ct, ca_ref, _cenario, prova in cts:
        refs = re.findall(r"CA-\d+", ca_ref)
        if not refs:
            erros.append(f"spec.md: {ct} não aponta para nenhum CA")
        for r in refs:
            if r not in cas:
                erros.append(f"spec.md: {ct} aponta para {r}, que não existe")
            cobertos.add(r)
        if VAZIO.match(prova):
            erros.append(f"spec.md: {ct} sem 'Prova'")
    for ca in cas:
        if ca not in cobertos:
            erros.append(f"spec.md: {ca} sem cenário de teste")

    if re.search(r"\*\*Tela:\*\*\s*sim", spec, re.I) and not (pasta / "prototipo.html").exists():
        erros.append("spec.md diz 'Tela: sim', mas falta prototipo.html")

    plano_p = pasta / "plano.md"
    if plano_p.exists():
        plano = plano_p.read_text(encoding="utf-8")
        for n, linha in enumerate(plano.splitlines(), 1):
            if PLACEHOLDER.search(linha):
                erros.append(f"plano.md:{n}: placeholder ou pendência: {linha.strip()[:90]}")
        for ca in cas:
            if not re.search(rf"\b{ca}\b", plano):
                erros.append(f"plano.md: {ca} não está em nenhuma fatia")
        if not re.search(r"^###\s*\[[ xX]\]\s*Fatia", plano, re.M):
            erros.append("plano.md: nenhuma fatia no formato '### [ ] Fatia 01 · tag — título'")
    return erros


def main() -> int:
    if len(sys.argv) > 1:
        pastas = [Path(a) for a in sys.argv[1:]]
    else:
        pastas = sorted(p for p in (RAIZ / "docs" / "specs").iterdir() if p.is_dir() and not p.name.startswith("_"))
    total = 0
    for pasta in pastas:
        erros = conferir(pasta)
        total += len(erros)
        for e in erros:
            print(f"{pasta.name}: {e}")
    if total:
        print(f"\n{total} problema(s). Corrija antes de seguir.", file=sys.stderr)
        return 1
    print(f"Specs coerentes ({len(pastas)}).")
    return 0


if __name__ == "__main__":
    sys.exit(main())

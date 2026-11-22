#!/usr/bin/env python3
"""Gera os subagentes do Claude Code e do Codex a partir de uma fonte única.

Fonte:   .agents/agents/<nome>.md   (frontmatter + instruções)
Saída:   .claude/agents/<nome>.md   e   .codex/agents/<nome>.toml

Gera só para a ferramenta escolhida na instalação (.agents/harness.toml: alvo = "claude" | "codex" | "ambos").
Arquivos gerados de uma ferramenta que saiu do alvo são removidos.

Uso:
  python3 scripts/harness/gerar_agentes.py           # gera
  python3 scripts/harness/gerar_agentes.py --check   # só confere se está em dia (CI)

Modelos e esforço por nível: .agents/modelos.toml (sobrescrito por .agents/modelos.local.toml, se existir).

Frontmatter aceito (subconjunto simples de YAML, sem dependências):
  name, description              obrigatórios
  nivel: leve | medio | forte    define modelo e esforço (ver modelos.toml)
  somente_leitura: true|false    Claude: bloqueia Edit/Write; Codex: instrução explícita
  skills: [a, b]                 Claude: pré-carrega; Codex: lista os caminhos nas instruções
  claude_model, claude_effort    opcionais, fogem do nível no Claude Code
  codex_model, codex_effort      opcionais, fogem do nível no Codex
  codex_sandbox                  opcional (ex.: read-only)
"""
from __future__ import annotations

import sys
import tomllib
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
FONTE = RAIZ / ".agents" / "agents"
SAIDA_CLAUDE = RAIZ / ".claude" / "agents"
SAIDA_CODEX = RAIZ / ".codex" / "agents"

CONFIG = RAIZ / ".agents" / "harness.toml"
MODELOS = RAIZ / ".agents" / "modelos.toml"
MODELOS_LOCAL = RAIZ / ".agents" / "modelos.local.toml"
ESFORCOS = {
    "claude": {"low", "medium", "high"},
    "codex": {"minimal", "low", "medium", "high", "xhigh"},
}


def carregar_niveis() -> dict:
    """{nivel: {"claude": {"model", "effort"}, "codex": {"model", "effort"}}}, com o local por cima."""
    if not MODELOS.exists():
        raise ValueError(f"falta {MODELOS.relative_to(RAIZ)}")
    niveis = tomllib.loads(MODELOS.read_text(encoding="utf-8"))
    if MODELOS_LOCAL.exists():
        for nivel, ferramentas in tomllib.loads(MODELOS_LOCAL.read_text(encoding="utf-8")).items():
            for ferramenta, valores in ferramentas.items():
                niveis.setdefault(nivel, {}).setdefault(ferramenta, {}).update(valores)
    return niveis


NIVEIS = carregar_niveis()


def ler_alvo() -> str:
    alvo = "ambos"
    if CONFIG.exists():
        alvo = tomllib.loads(CONFIG.read_text(encoding="utf-8")).get("alvo", "ambos")
    if alvo not in ("claude", "codex", "ambos"):
        raise ValueError(f".agents/harness.toml: alvo '{alvo}' inválido (claude, codex ou ambos)")
    return alvo
AVISOS: list[str] = []
AVISO = "GERADO por scripts/harness/gerar_agentes.py a partir de .agents/agents/{nome}.md. Não edite aqui."


def ler_fonte(caminho: Path) -> tuple[dict, str]:
    texto = caminho.read_text(encoding="utf-8")
    if not texto.startswith("---\n"):
        raise ValueError(f"{caminho}: falta frontmatter")
    _, cabecalho, corpo = texto.split("---\n", 2)
    meta: dict = {}
    for linha in cabecalho.splitlines():
        if not linha.strip() or linha.lstrip().startswith("#"):
            continue
        chave, _, valor = linha.partition(":")
        valor = valor.strip()
        if valor.startswith("[") and valor.endswith("]"):
            meta[chave.strip()] = [v.strip() for v in valor[1:-1].split(",") if v.strip()]
        elif valor in ("true", "false"):
            meta[chave.strip()] = valor == "true"
        else:
            meta[chave.strip()] = valor
    for obrigatorio in ("name", "description"):
        if not meta.get(obrigatorio):
            raise ValueError(f"{caminho}: falta '{obrigatorio}'")
    if meta["name"] != caminho.stem:
        raise ValueError(f"{caminho}: name '{meta['name']}' difere do nome do arquivo")
    nivel = meta.get("nivel", "medio")
    if nivel not in NIVEIS:
        raise ValueError(f"{caminho}: nivel '{nivel}' não está em .agents/modelos.toml (há: {', '.join(NIVEIS)})")
    meta["nivel"] = nivel
    return meta, corpo.strip() + "\n"


def resolver(meta: dict, ferramenta: str) -> tuple[str, str]:
    """Modelo e esforço do agente numa ferramenta: frontmatter > modelos.local.toml > modelos.toml."""
    base = NIVEIS[meta["nivel"]].get(ferramenta, {})
    modelo = meta.get(f"{ferramenta}_model", base.get("model", ""))
    esforco = meta.get(f"{ferramenta}_effort", base.get("effort", ""))
    if esforco and esforco not in ESFORCOS[ferramenta]:
        raise ValueError(
            f"{meta['name']}: esforço '{esforco}' inválido para {ferramenta} (use {', '.join(sorted(ESFORCOS[ferramenta]))})"
        )
    return modelo, esforco


def gerar_claude(meta: dict, corpo: str) -> str:
    modelo, esforco = resolver(meta, "claude")
    linhas = [
        "---",
        f"name: {meta['name']}",
        f"description: {_yaml_str(meta['description'])}",
    ]
    if modelo:
        linhas.append(f"model: {modelo}")
    if esforco:
        linhas.append(f"effort: {esforco}")
    if meta.get("somente_leitura"):
        linhas.append("disallowedTools: Edit, Write, MultiEdit, NotebookEdit")
    if meta.get("skills"):
        linhas.append("skills:")
        linhas += [f"  - {s}" for s in meta["skills"]]
    linhas += ["---", "", f"<!-- {AVISO.format(nome=meta['name'])} -->", "", corpo]
    return "\n".join(linhas)


def gerar_codex(meta: dict, corpo: str) -> str:
    modelo, esforco = resolver(meta, "codex")
    instrucoes = corpo
    extras = []
    if meta.get("somente_leitura"):
        extras.append("Você não cria, edita nem apaga arquivos (nem por shell, nem por apply_patch). Pode ler e rodar testes.")
    if meta.get("skills"):
        caminhos = ", ".join(f".agents/skills/{s}/SKILL.md" for s in meta["skills"])
        extras.append(f"Antes de começar, leia as skills que guiam este papel: {caminhos}.")
    if extras:
        instrucoes = "\n".join(extras) + "\n\n" + corpo
    linhas = [
        f"# {AVISO.format(nome=meta['name'])}",
        f"name = {_toml_str(meta['name'])}",
        f"description = {_toml_str(meta['description'])}",
    ]
    if modelo:
        linhas.append(f"model = {_toml_str(modelo)}")
    else:
        AVISOS.append(f"{meta['name']}: sem modelo do Codex; vai herdar o modelo da sessão")
    if esforco:
        linhas.append(f"model_reasoning_effort = {_toml_str(esforco)}")
    if meta.get("codex_sandbox"):
        linhas.append(f"sandbox_mode = {_toml_str(meta['codex_sandbox'])}")
    corpo_toml = instrucoes.replace("\\", "\\\\").replace('"""', '\\"\\"\\"')
    linhas.append(f'developer_instructions = """\n{corpo_toml}"""')
    return "\n".join(linhas) + "\n"


def _toml_str(valor: str) -> str:
    return '"' + valor.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _yaml_str(valor: str) -> str:
    return '"' + valor.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main() -> int:
    so_conferir = "--check" in sys.argv[1:]
    fontes = sorted(FONTE.glob("*.md"))
    if not fontes:
        print(f"Nenhuma fonte em {FONTE}", file=sys.stderr)
        return 1
    alvo = ler_alvo()
    esperado: dict[Path, str] = {}
    for fonte in fontes:
        meta, corpo = ler_fonte(fonte)
        if alvo in ("claude", "ambos"):
            esperado[SAIDA_CLAUDE / f"{meta['name']}.md"] = gerar_claude(meta, corpo)
        if alvo in ("codex", "ambos"):
            esperado[SAIDA_CODEX / f"{meta['name']}.toml"] = gerar_codex(meta, corpo)

    # Gerados que não têm mais fonte (só os que têm o aviso de gerado)
    orfaos = [
        p for pasta in (SAIDA_CLAUDE, SAIDA_CODEX) if pasta.exists()
        for p in pasta.iterdir()
        if p not in esperado and "GERADO por scripts/harness/gerar_agentes.py" in p.read_text(encoding="utf-8", errors="ignore")
    ]

    for aviso in AVISOS:
        print(f"aviso: {aviso}", file=sys.stderr)

    if so_conferir:
        divergentes = [p for p, c in esperado.items() if not p.exists() or p.read_text(encoding="utf-8") != c]
        if divergentes or orfaos:
            for p in divergentes + orfaos:
                print(f"desatualizado: {p.relative_to(RAIZ)}", file=sys.stderr)
            print("Rode: python3 scripts/harness/gerar_agentes.py", file=sys.stderr)
            return 1
        print(f"Subagentes em dia ({len(fontes)} fontes, alvo: {alvo}).")
        return 0

    for caminho, conteudo in esperado.items():
        caminho.parent.mkdir(parents=True, exist_ok=True)
        caminho.write_text(conteudo, encoding="utf-8")
    for p in orfaos:
        p.unlink()
    print(f"Gerados {len(esperado)} arquivos para '{alvo}' a partir de {len(fontes)} fontes; {len(orfaos)} órfãos removidos.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

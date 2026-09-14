#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(
  "AGENTS.md"
  "catalog.json"
  ".claude-plugin/marketplace.json"
  ".agents/plugins/marketplace.json"
  "plugins/agent-engineering-system/plugin.json"
  "plugins/agent-engineering-system/.codex-plugin/plugin.json"
  "plugins/agent-engineering-system/.claude-plugin/plugin.json"
  "plugins/agent-engineering-system/skills/code-quality/SKILL.md"
  "plugins/agent-engineering-system/skills/semantic-architecture/SKILL.md"
  "plugins/agent-engineering-system/skills/technical-communication/SKILL.md"
  ".agents/core/AGENT_RULES.md"
  ".agents/architecture/system.md"
  ".agents/architecture/_templates/system.md"
  ".agents/skills/project-research/SKILL.md"
  "docs/OPERATING_SYSTEM_SPLIT.md"
  "docs/OPERATING_SYSTEM_SPLIT.json"
  "docs/UPSTREAM_SKILLS.md"
)

for file in "${required[@]}"; do
  [[ -s "$ROOT/$file" ]] || { echo "missing: $file" >&2; exit 1; }
done

[[ ! -e "$ROOT/plugin.json" ]] || { echo "root plugin.json must not make the catalog look like one plugin" >&2; exit 1; }
[[ ! -e "$ROOT/.codex-plugin/plugin.json" ]] || { echo "root .codex-plugin/plugin.json must not make the catalog look like one plugin" >&2; exit 1; }
[[ ! -e "$ROOT/.claude-plugin/plugin.json" ]] || { echo "root .claude-plugin/plugin.json must be a marketplace only" >&2; exit 1; }
[[ ! -e "$ROOT/skills" ]] || { echo "root skills/ must not duplicate a maintained plugin skill tree" >&2; exit 1; }

python3 - "$ROOT" <<'PY'
import json
import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
schema = "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"
expected_skills = {"code-quality", "semantic-architecture", "technical-communication"}


def load_json(relative):
    path = root / relative
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError as error:
        raise SystemExit(f"invalid JSON in {relative}: {error}")


def require_relative(relative):
    path = root / relative
    if not path.is_file() or not path.stat().st_size:
        raise SystemExit(f"missing or empty file: {relative}")
    return path


catalog = load_json("catalog.json")
if catalog.get("formatVersion") != 1:
    raise SystemExit("catalog.json must use formatVersion 1")
if catalog.get("name") != "agent-starter":
    raise SystemExit("catalog.json has the wrong catalog identity")
if not isinstance(catalog.get("plugins"), list) or not catalog["plugins"]:
    raise SystemExit("catalog.json must contain at least one plugin entry")
if not isinstance(catalog.get("owner"), dict) or catalog["owner"].get("email") != "lalitkapoor@gmail.com":
    raise SystemExit("catalog.json must preserve the configured commit/author email")

entries = {entry.get("name"): entry for entry in catalog["plugins"]}
if len(entries) != len(catalog["plugins"]):
    raise SystemExit("catalog.json plugin names must be unique")
maintained = entries.get("agent-engineering-system")
if not maintained or maintained.get("ownership") != "maintained":
    raise SystemExit("catalog.json must contain the maintained agent-engineering-system entry")
if maintained.get("path") != "./plugins/agent-engineering-system":
    raise SystemExit("maintained plugin path must be ./plugins/agent-engineering-system")

maintained_root = root / maintained["path"]
try:
    maintained_root.resolve().relative_to(root)
except ValueError:
    raise SystemExit("maintained plugin path must stay inside the repository")

portable = load_json("plugins/agent-engineering-system/plugin.json")
allowed_portable_keys = {
    "$schema",
    "name",
    "version",
    "description",
    "author",
    "homepage",
    "repository",
    "license",
    "keywords",
    "extensions",
}
unknown_portable_keys = set(portable) - allowed_portable_keys
if unknown_portable_keys:
    raise SystemExit(f"maintained plugin has unsupported portable manifest keys: {sorted(unknown_portable_keys)}")
if portable.get("$schema") != schema:
    raise SystemExit("maintained plugin must declare the Agent Plugins 1.0 schema")
if not isinstance(portable.get("name"), str) or not re.fullmatch(r"(?!.*(?:--|\.\.))[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?", portable["name"]):
    raise SystemExit("maintained plugin name must be a valid Agent Plugins 1.0 package name")
if portable.get("name") != maintained["name"] or portable.get("version") != maintained["version"]:
    raise SystemExit("maintained plugin identity must match catalog.json")
if not isinstance(portable.get("author"), dict) or portable["author"].get("email") != "lalitkapoor@gmail.com":
    raise SystemExit("maintained plugin must preserve the configured author email")
if not isinstance(portable.get("keywords"), list) or not all(isinstance(item, str) for item in portable["keywords"]):
    raise SystemExit("maintained plugin keywords must be an array of strings")

codex = load_json("plugins/agent-engineering-system/.codex-plugin/plugin.json")
claude = load_json("plugins/agent-engineering-system/.claude-plugin/plugin.json")
for label, manifest in (("Codex", codex), ("Claude", claude)):
    for field in ("name", "version", "description", "author"):
        if manifest.get(field) != portable.get(field):
            raise SystemExit(f"{label} manifest does not preserve plugin identity field {field}")
if codex.get("skills") != "./skills/":
    raise SystemExit("Codex manifest must expose the maintained plugin's canonical skills/ directory")
if "skills" in claude:
    raise SystemExit("Claude manifest must use default root skills/ discovery")

skill_root = maintained_root / "skills"
skill_names = {path.name for path in skill_root.iterdir() if path.is_dir()}
if not expected_skills <= skill_names:
    raise SystemExit(f"maintained plugin is missing skills: {sorted(expected_skills - skill_names)}")
for skill_name in sorted(skill_names):
    skill_file = skill_root / skill_name / "SKILL.md"
    if not skill_file.is_file():
        raise SystemExit(f"plugin skill is missing SKILL.md: {skill_name}")
    lines = skill_file.read_text().splitlines()
    if not lines or lines[0] != "---":
        raise SystemExit(f"plugin skill is missing frontmatter: {skill_name}")
    try:
        end = lines.index("---", 1)
    except ValueError:
        raise SystemExit(f"plugin skill frontmatter is not closed: {skill_name}")
    metadata = {}
    for line in lines[1:end]:
        key, separator, value = line.partition(":")
        if not separator or not key.strip() or not value.strip():
            raise SystemExit(f"invalid plugin skill frontmatter in {skill_name}")
        metadata[key.strip()] = value.strip()
    if metadata.get("name") != skill_name:
        raise SystemExit(f"plugin skill name does not match directory: {skill_name}")
    if not metadata.get("description"):
        raise SystemExit(f"plugin skill description is missing: {skill_name}")

project_skills_root = root / ".agents" / "skills"
project_skill_names = {path.name for path in project_skills_root.iterdir() if path.is_dir()}
overlap = expected_skills & project_skill_names
if overlap:
    raise SystemExit(f"maintained skill names collide with project-local skills: {sorted(overlap)}")

tracked_files = subprocess.check_output(
    ["git", "ls-files", "--cached"], cwd=root, text=True
).splitlines()
for tracked_file in tracked_files:
    parts = pathlib.PurePosixPath(tracked_file).parts
    if (len(parts) >= 2 and parts[0] == "skills" and parts[1] in expected_skills) or (len(parts) >= 3 and parts[2] in expected_skills and parts[0:2] in {
        (".agents", "skills"),
        (".claude", "skills"),
        (".cursor", "skills"),
        (".codex-plugin", "skills"),
    }):
        raise SystemExit(f"tracked duplicate of maintained plugin skill: {tracked_file}")

for entry in catalog["plugins"]:
    if entry["ownership"] not in {"maintained", "upstream"}:
        raise SystemExit(f"invalid ownership for catalog entry: {entry['name']}")
    if entry["ownership"] == "upstream":
        provenance = entry.get("provenance")
        if not isinstance(provenance, dict) or not provenance.get("repository") or not provenance.get("ref"):
            raise SystemExit(f"upstream dependency {entry['name']} must declare a repository and ref")
        if "sha" in provenance:
            raise SystemExit(f"upstream dependency {entry['name']} must not be commit-pinned")
    for runtime in ("claude", "codex", "cursor"):
        definition = entry.get("runtimes", {}).get(runtime)
        if not definition:
            raise SystemExit(f"catalog entry {entry['name']} has no {runtime} route")
        if definition.get("kind") == "plugin":
            source = definition.get("source")
            if entry["ownership"] == "upstream":
                if not isinstance(source, dict) or not source.get("source"):
                    raise SystemExit(f"upstream plugin {entry['name']} must declare an external source for {runtime}")
                if "sha" in source:
                    raise SystemExit(f"upstream dependency {entry['name']} must not be commit-pinned for {runtime}")
                if source.get("source") in {"github", "git-subdir"} and not source.get("ref"):
                    raise SystemExit(f"upstream plugin {entry['name']} must declare a ref for {runtime}")
        elif definition.get("kind") == "skills":
            if not definition.get("source") or not definition.get("agent") or not definition.get("skills"):
                raise SystemExit(f"skill-only route for {entry['name']} is incomplete for {runtime}")
        else:
            raise SystemExit(f"unknown route kind for {entry['name']} on {runtime}")

claude_marketplace = load_json(".claude-plugin/marketplace.json")
codex_marketplace = load_json(".agents/plugins/marketplace.json")
if claude_marketplace.get("name") != catalog["name"] or codex_marketplace.get("name") != catalog["name"]:
    raise SystemExit("generated marketplace identity does not match catalog.json")


def plugin_names(marketplace):
    plugins = marketplace.get("plugins")
    if not isinstance(plugins, list):
        raise SystemExit("generated marketplace must contain a plugins array")
    names = [plugin.get("name") for plugin in plugins]
    if any(not name for name in names) or len(names) != len(set(names)):
        raise SystemExit("generated marketplace plugin names must be unique")
    return set(names)


expected_claude = {name for name, entry in entries.items() if entry["runtimes"]["claude"]["kind"] == "plugin"}
expected_codex = {name for name, entry in entries.items() if entry["runtimes"]["codex"]["kind"] == "plugin"}
if plugin_names(claude_marketplace) != expected_claude:
    raise SystemExit("Claude marketplace entries do not match catalog plugin routes")
if plugin_names(codex_marketplace) != expected_codex:
    raise SystemExit("Codex marketplace entries do not match catalog plugin routes")

claude_entries = {plugin["name"]: plugin for plugin in claude_marketplace["plugins"]}
codex_entries = {plugin["name"]: plugin for plugin in codex_marketplace["plugins"]}

def expected_source(entry, runtime):
    definition = entry["runtimes"][runtime]
    if definition["source"] == "local":
        return entry["path"] if runtime == "claude" else {"source": "local", "path": entry["path"]}
    return definition["source"]

for name, entry in entries.items():
    for runtime, marketplace_entries in (("claude", claude_entries), ("codex", codex_entries)):
        definition = entry["runtimes"][runtime]
        if definition["kind"] != "plugin":
            continue
        marketplace_entry = marketplace_entries[name]
        if marketplace_entry.get("source") != expected_source(entry, runtime):
            raise SystemExit(f"{runtime} marketplace source for {name} is stale")
        if marketplace_entry.get("description") != entry.get("description"):
            raise SystemExit(f"{runtime} marketplace description for {name} is stale")

agents_text = require_relative("AGENTS.md").read_text()
for required_text in (
    "technical-communication",
    "comments, commit messages, pull requests",
    "plugins/agent-engineering-system/skills/technical-communication/SKILL.md",
):
    if required_text not in agents_text:
        raise SystemExit(f"AGENTS.md is missing technical communication guidance: {required_text}")

mapping = load_json("docs/OPERATING_SYSTEM_SPLIT.json")
if mapping.get("source_numbered_sections") != 82:
    raise SystemExit("operating-system split must continue to cover 82 original sections")
numbers = [item["number"] for item in mapping["core_sections"] + mapping["code_quality_sections"]]
expected_numbers = list(range(1, mapping["source_numbered_sections"] + 1))
if sorted(numbers) != expected_numbers or len(numbers) != len(set(numbers)):
    raise SystemExit("operating-system split is incomplete or duplicated")

print(f"Catalog, maintained plugin, native marketplace views, and {len(expected_skills)} required skills are valid.")
print(f"Catalog includes {len(catalog['plugins'])} offerings; {len(expected_claude)} Claude and {len(expected_codex)} Codex plugin routes are generated.")
print(f"Operating-system split covers all {len(expected_numbers)} numbered sections.")
PY

node "$ROOT/.agents/bootstrap.mjs" --check

echo "Catalog verification passed."

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(
  "AGENTS.md"
  "plugin.json"
  "skills/code-quality/SKILL.md"
  "skills/semantic-architecture/SKILL.md"
  ".agents/core/AGENT_RULES.md"
  ".agents/architecture/system.md"
  ".agents/architecture/_templates/system.md"
  "docs/OPERATING_SYSTEM_SPLIT.md"
  "docs/OPERATING_SYSTEM_SPLIT.json"
  "docs/UPSTREAM_SKILLS.md"
)

for f in "${required[@]}"; do
  [[ -s "$ROOT/$f" ]] || { echo "missing: $f" >&2; exit 1; }
done

python3 - "$ROOT" <<'PY'
import json
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
schema = "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"
manifest_path = root / "plugin.json"
manifest = json.loads(manifest_path.read_text())
allowed_manifest_keys = {
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
unknown_keys = set(manifest) - allowed_manifest_keys
if unknown_keys:
    raise SystemExit(f"plugin.json has unsupported top-level keys: {sorted(unknown_keys)}")
if manifest.get("$schema") != schema:
    raise SystemExit("plugin.json must declare the Agent Plugins 1.0 schema")
name = manifest.get("name")
if not isinstance(name, str) or not 1 <= len(name) <= 64 or not re.fullmatch(r"(?!.*(?:--|\.\.))[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?", name):
    raise SystemExit("plugin.json name must be a valid Agent Plugins 1.0 package name")
if "author" in manifest:
    author = manifest["author"]
    if not isinstance(author, dict) or set(author) - {"name", "email", "url"}:
        raise SystemExit("plugin.json author must contain only name, email, and url")
if "keywords" in manifest and (not isinstance(manifest["keywords"], list) or not all(isinstance(item, str) for item in manifest["keywords"])):
    raise SystemExit("plugin.json keywords must be an array of strings")
if "extensions" in manifest and (not isinstance(manifest["extensions"], dict) or not all(isinstance(value, dict) for value in manifest["extensions"].values())):
    raise SystemExit("plugin.json extensions must be an object of namespace objects")

plugin_skills_root = root / "skills"
plugin_skill_names = set()
for skill_dir in sorted(path for path in plugin_skills_root.iterdir() if path.is_dir()):
    skill_name = skill_dir.name
    plugin_skill_names.add(skill_name)
    skill_path = skill_dir / "SKILL.md"
    if not skill_path.is_file():
        raise SystemExit(f"plugin skill is missing SKILL.md: {skill_name}")
    lines = skill_path.read_text().splitlines()
    if not lines or lines[0] != "---":
        raise SystemExit(f"plugin skill is missing frontmatter: {skill_name}")
    try:
        end = lines.index("---", 1)
    except ValueError:
        raise SystemExit(f"plugin skill frontmatter is not closed: {skill_name}")
    metadata = {}
    for line in lines[1:end]:
        key, separator, value = line.partition(":")
        if not separator or not key or not value.strip():
            raise SystemExit(f"invalid plugin skill frontmatter in {skill_name}")
        metadata[key.strip()] = value.strip()
    if metadata.get("name") != skill_name:
        raise SystemExit(f"plugin skill name does not match directory: {skill_name}")
    if not metadata.get("description"):
        raise SystemExit(f"plugin skill description is missing: {skill_name}")

project_skills_root = root / ".agents" / "skills"
project_skill_names = set()
if project_skills_root.is_dir():
    project_skill_names = {path.name for path in project_skills_root.iterdir() if path.is_dir()}
overlap = plugin_skill_names & project_skill_names
if overlap:
    raise SystemExit(f"duplicate canonical skill names across plugin and host: {sorted(overlap)}")

source_skills = {}
for source_root in (plugin_skills_root, project_skills_root):
    if not source_root.is_dir():
        continue
    for skill_dir in source_root.iterdir():
        skill_path = skill_dir / "SKILL.md"
        if skill_dir.is_dir() and skill_path.is_file():
            source_skills[skill_dir.name] = skill_path

for client in (".cursor", ".claude"):
    output_root = root / client / "skills"
    marker = output_root / ".agent-engineering-system-compat"
    if not marker.is_file():
        continue
    generated_names = {line.strip() for line in marker.read_text().splitlines() if line.strip()}
    missing = sorted(set(source_skills) - generated_names)
    unknown = sorted(generated_names - set(source_skills))
    if missing or unknown:
        raise SystemExit(f"{client}/skills compatibility manifest is stale; missing={missing}, unknown={unknown}")
    for name in generated_names:
        source_path = source_skills[name]
        output_path = output_root / name / "SKILL.md"
        if not output_path.is_file() or output_path.read_text() != source_path.read_text():
            raise SystemExit(f"stale compatibility skill output: {client}/skills/{name}")

mapping = json.loads((root / "docs" / "OPERATING_SYSTEM_SPLIT.json").read_text())
numbers = [item["number"] for item in mapping["core_sections"] + mapping["code_quality_sections"]]
expected = list(range(1, mapping["source_numbered_sections"] + 1))
if sorted(numbers) != expected or len(numbers) != len(set(numbers)):
    raise SystemExit("operating-system split is incomplete or duplicated")

print(f"Plugin manifest and {len(plugin_skill_names)} portable skills are valid.")
print(f"Operating-system split covers all {len(expected)} numbered sections.")
PY

node "$ROOT/.agents/bootstrap.mjs" --check

echo "Agent Plugins 1.0 verification passed."

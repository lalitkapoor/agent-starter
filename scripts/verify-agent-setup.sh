#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(
  "AGENTS.md"
  ".agents/OPERATING_SYSTEM_SPLIT.json"
  ".agents/OPERATING_SYSTEM_SPLIT.md"
  ".agents/skills/code-quality/SKILL.md"
  ".agents/core/AGENT_RULES.md"
  ".agents/skills/semantic-architecture/SKILL.md"
  ".agents/architecture/system.md"
  ".agents/architecture/_templates/system.md"
  ".agents/UPSTREAM_SKILLS.md"
)

for f in "${required[@]}"; do
  [[ -s "$ROOT/$f" ]] || { echo "missing: $f" >&2; exit 1; }
done

grep -q "semantic-architecture" "$ROOT/AGENTS.md"
grep -q "Skill: Semantic Architecture" "$ROOT/.agents/skills/semantic-architecture/SKILL.md"
grep -q "Skill: Code Quality" "$ROOT/.agents/skills/code-quality/SKILL.md"

if [[ -d "$ROOT/skills" ]]; then
  echo "legacy top-level skills/ directory exists; canonical skills must live under .agents/skills/" >&2
  exit 1
fi

echo "Agent setup verification passed."


python3 - "$ROOT" <<'PY'
import json, pathlib, sys, re
root = pathlib.Path(sys.argv[1])
manifest = json.loads((root / ".agents/OPERATING_SYSTEM_SPLIT.json").read_text())
nums = [x["number"] for x in manifest["core_sections"]] + [x["number"] for x in manifest["code_quality_sections"]]
expected = list(range(1, manifest["source_numbered_sections"] + 1))
if sorted(nums) != expected:
    raise SystemExit(f"operating-system split is incomplete/duplicated: got {sorted(nums)}, expected {expected}")
if len(nums) != len(set(nums)):
    raise SystemExit("operating-system split contains duplicate section numbers")
print(f"Operating-system split covers all {len(expected)} numbered sections.")
PY

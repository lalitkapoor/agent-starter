# Upstream Agent Workflow Dependencies

Project-owned policy lives in `.agents/`.
Project-owned skills live under `.agents/skills/`.

Upstream skills supplement the repository; they do not become the source of truth for product behavior or architectural intent.

## Precedence

1. **pstack** — primary workflow/orchestration for non-trivial engineering work.
2. **code-quality** — repository-owned detailed engineering quality bar.
3. **Project-owned skills** — project/platform/product-specific behavior.
4. **semantic-architecture** — persistent hierarchical system modeling.
5. **Selected Matt Pocock skills** — specialist design, diagnosis, research, review, and agent-writing references.

When skills overlap, do not mechanically execute both workflows. pstack owns process choices such as architecture workflow, TDD, verification, adversarial review, and proof.

## pstack

Official source:
`https://github.com/cursor/plugins/tree/main/pstack`

The setup installs the complete official pstack Cursor plugin for Cursor and exposes official pstack skill directories to project-local discovery when possible.

Cross-runtime supplement:
`https://github.com/michael-denyer/pstack-claude`

It only fills skill names absent from official pstack.

## Matt Pocock skills

Official source:
`https://github.com/mattpocock/skills`

Selected:
- `codebase-design`
- `domain-modeling`
- `diagnosing-bugs`
- `research`
- `improve-codebase-architecture`
- `code-review`
- `prototype`
- `writing-for-agents`
- `handoff`

Do not install overlapping Matt workflow skills such as TDD as the primary workflow because pstack owns that role.

## Project-owned skills

Canonical copies live under `.agents/skills/`.
`setup.sh` copies them into runtime-specific discovery directories.

## Updating dependencies

1. inspect upstream changes,
2. rerun setup,
3. review `.agent-deps.lock`,
4. ensure upstream instructions do not conflict with `AGENTS.md`,
5. run `scripts/verify-agent-setup.sh`.


## code-quality

Canonical source:

```text
.agents/skills/code-quality/SKILL.md
```

This is the reusable engineering operating system for non-trivial implementation and review work. It intentionally contains the detailed rules that would be too large and noisy for the always-loaded `AGENTS.md`.

It should be used together with pstack, not instead of pstack.

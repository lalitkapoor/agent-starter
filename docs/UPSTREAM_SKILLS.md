# Curated Upstream Dependencies

This repository is a catalog and installer. It owns the selection and declared
installation routes below; it does not own the upstream plugin or skill source
code.

The maintained engineering plugin is under
`plugins/agent-engineering-system/`. Its canonical skills are
`code-quality`, `semantic-architecture`, and `technical-communication`.

Project-owned policy and architecture state live in the consuming project.
Architecture documents are colocated as `ARCHITECTURE.md` files beside the
meaningful subsystems they describe. Project-specific skills live under that
project's `.agents/skills/`.

Upstream offerings supplement the maintained plugin; they do not become the
source of truth for product behavior or architectural intent.

## Precedence

1. **pstack** — primary workflow/orchestration for non-trivial engineering work.
2. **code-quality** — repository-owned detailed engineering quality bar.
3. **technical-communication** — repository-owned standard for clear engineering writing.
4. **Project-owned skills** — project/platform/product-specific behavior.
5. **semantic-architecture** — persistent hierarchical system modeling.
6. **show-me** — optional visual explanations for complex code and system relationships.
7. **Selected Matt Pocock skills** — specialist design, diagnosis, research, review, and agent-writing references.

When skills overlap, do not mechanically execute both workflows. pstack owns process choices such as architecture workflow, TDD, verification, adversarial review, and proof.

## pstack

Official source:
`https://github.com/cursor/plugins/tree/main/pstack`

`catalog.json` selects the official pstack plugin for each supported runtime.
`setup.sh` installs it through the native route where one exists. It does not
fold pstack into `plugins/agent-engineering-system/`.

Cross-runtime supplement:
`https://github.com/michael-denyer/pstack-claude`

The upstream repository includes a native Claude Code plugin at
`plugins/pstack/.claude-plugin/plugin.json` and a Codex plugin overlay. The
catalog follows its `main` ref and installs the plugin through its native
marketplace entry:

```text
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

For Cursor, the installer fetches the `pstack` plugin from the declared `main`
ref in `cursor/plugins` into Cursor's local plugin directory. No pstack files are
copied into the maintained engineering plugin.

## HumanLayer show-me

Official source:
`https://github.com/humanlayer/skills/tree/main/plugins/show-me`

`show-me` helps an agent explain a topic with concise diagrams, code-shape
sketches, and focused HTML artifacts. It is an optional visual explanation aid,
not a replacement for the engineering workflow or architecture model.

Claude Code uses HumanLayer's native `show-me` plugin at
`plugins/show-me`. Codex and Cursor use the skill-only `npx skills` route for
the selected `show-me` skill. The catalog follows the upstream `main` ref and
does not copy the skill into the maintained engineering plugin.

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

Claude Code can install the upstream `mattpocock-skills` plugin through the
catalog's Claude marketplace entry. Codex and Cursor use the skill-only
`npx skills` route for the selected names. In neither case are those skills
copied into `plugins/agent-engineering-system/`.

## Skill-only compatibility

`npx skills` installs skill files, not full plugin components. The installer
uses it for selected upstream skill-only offerings, currently Matt Pocock's
skills and HumanLayer's `show-me`, on runtimes without a native plugin route.
Pass `--compat` only when a runtime cannot load the maintained plugin natively;
this creates generated runtime skill copies and never changes canonical
ownership.

## Updating dependencies

1. inspect upstream changes,
2. update the upstream repository/ref, source route, or selected skills in `catalog.json`,
3. regenerate with `node .agents/bootstrap.mjs`,
4. ensure upstream instructions do not conflict with the consuming project's `AGENTS.md`,
5. run `scripts/verify-catalog.sh`.

Upstream dependencies intentionally use declared refs such as `main` rather
than commit SHA pins. A later installation may therefore receive newer
upstream changes. This catalog curates which upstream offerings are installed;
it is not a lockfile and does not vendor their source.


## code-quality

Canonical source:

```text
plugins/agent-engineering-system/skills/code-quality/SKILL.md
```

This is the reusable engineering operating system for non-trivial implementation and review work. It intentionally contains the detailed rules that would be too large and noisy for the always-loaded `AGENTS.md`.

It should be used together with pstack, not instead of pstack.

## technical-communication

Canonical source:

```text
plugins/agent-engineering-system/skills/technical-communication/SKILL.md
```

Use it for comments, commit messages, pull requests, technical documentation,
RFCs, architecture diagrams, technical specifications, and handoffs. It is
maintained by this repository and is installed with the engineering plugin.

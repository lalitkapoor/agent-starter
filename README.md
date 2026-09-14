# Agent Engineering System

This repository is a reusable, multi-harness engineering system for coding
agents. It keeps one canonical set of engineering skills and wraps that
content with the smallest native packaging metadata needed by each supported
runtime.

## Architecture

```text
                         agent-starter
                              │
                       canonical content
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
     code-quality     semantic-architecture     policy
          │                   │                   │
          └───────────────┬───┘                   │
                          │                       │
                    canonical skills/       .agents/core/
                          │
               ┌──────────┼──────────┐
               ▼          ▼          ▼
             Codex      Claude     Cursor/other
```

The reusable engineering behavior is stored once:

```text
skills/
├── code-quality/SKILL.md
└── semantic-architecture/SKILL.md
```

The manifests identify that same package for different runtimes. They do not
contain or copy the skill files.

## Package boundaries

### Portable Agent Plugins package

```text
plugin.json
skills/
```

The root `plugin.json` is the vendor-neutral Agent Plugins 1.0 representation.
Portable clients discover reusable skills from the fixed root `skills/`
directory. See the [Agent Plugins documentation](https://docs.github.com/en/copilot/concepts/agents/about-plugins).

### Codex

```text
.codex-plugin/plugin.json
```

This Codex-specific manifest points to `./skills/` and contains no second copy
of the skills. Current OpenAI documentation supports this overlay while also
documenting the root portable manifest as the portable package entrypoint. See
[OpenAI's plugin packaging guide](https://developers.openai.com/plugins/build/plugins).

A Codex `marketplace.json` is an installation and registry catalog, not the
plugin package. This repository intentionally does not include
`.agents/plugins/marketplace.json`; create or configure a separate marketplace
only when a particular Codex installation requires one.

### Claude Code

```text
.claude-plugin/plugin.json
skills/
```

Claude Code discovers `skills/` at the plugin root. Only the manifest belongs
inside `.claude-plugin/`; reusable skills remain at the repository root. See
[Claude Code's plugin documentation](https://code.claude.com/docs/en/plugins).

### Cursor

Cursor supports the portable root `plugin.json` format. The committed
`.cursor/rules/00-project-agents.mdc` is only a thin repository-instruction
adapter. This package has no Cursor-specific agents, commands, hooks, or MCP
servers, so it does not add a `.cursor-plugin/` manifest.

See [Cursor's plugin documentation](https://cursor.com/docs/plugins) for its
portable and Cursor-specific plugin formats.

## Repository-local state

The plugin package and the repository's own control plane are separate:

```text
AGENTS.md                         # always-loaded contract for this repository
.agents/
├── core/AGENT_RULES.md           # detailed operating policy
├── architecture/                 # semantic model of this repository
├── skills/                       # repository-specific skills only
└── bootstrap.mjs                 # source for generated harness adapters
```

`skills/semantic-architecture/` explains how to maintain an architecture
model. `.agents/architecture/` records what this repository means. A product
repository consuming this system must supply its own `AGENTS.md`, architecture
model, and project-specific skills; it must not copy this repository's model
as if it described the product.

The root `AGENTS.md` in this repository describes how to maintain the
engineering system itself. It is not a universal replacement for a consuming
project's repository contract.

## Using this with a product repository

Install or register this repository as a plugin in the agent runtime, then
keep product-specific state in the product repository:

```text
my-product/
├── AGENTS.md
├── .agents/
│   ├── architecture/
│   │   └── system.md
│   └── skills/
│       └── product-specific-skill/
└── src/
```

The product's contract should tell agents to use the installed
`agent-engineering-system` skills, inspect the relevant product architecture
path, and load product-specific skills when their triggers apply. During work,
the agent combines:

```text
product AGENTS.md
    + this plugin's code-quality and semantic-architecture skills
    + product .agents/architecture/
    + product .agents/skills/
    + pstack, when separately installed
```

When a change alters product responsibilities, ownership, boundaries, or
invariants, update the product's `.agents/architecture/` model—not this
plugin's architecture state.

## Native installation and testing

The installation command is runtime-specific. Use native plugin loading rather
than copying skills into `.claude/skills/` or `.cursor/skills/`.

### Claude Code

Test a local checkout directly:

```bash
claude --plugin-dir /path/to/agent-starter
```

The skills are then namespaced by the plugin, for example
`/agent-engineering-system:code-quality`. For team or community distribution,
publish or add the plugin through a Claude Code marketplace. See [Claude Code's
plugin sharing guidance](https://code.claude.com/docs/en/plugins#share-your-plugins).

### Codex

Use the Codex plugin directory or marketplace flow appropriate to the Codex
surface you use. For local/repository distribution, the marketplace is a
separate catalog that points at this plugin repository; it is not added here
automatically. See [OpenAI's local plugin installation
guidance](https://developers.openai.com/plugins/build/plugins#install-a-local-plugin-manually).

### Cursor

Install the repository through Cursor's Plugins/Customize surface. Cursor can
load the portable root Agent Plugins package directly; no `.cursor/skills/`
copy is needed for current Cursor versions.

## Setup script

`setup.sh` is repository initialization and dependency orchestration. It does
not replace native plugin installation in a consuming project.

Run without network access to regenerate adapters and verify the package:

```bash
./setup.sh --local-only
```

Run full setup to install separate upstream workflow dependencies:

```bash
./setup.sh
```

The optional `--compat` flag is retained only for older or non-plugin clients.
It creates ignored, generated copies under `.cursor/skills/` and
`.claude/skills/`; those are legacy outputs, never canonical sources:

```bash
./setup.sh --local-only --compat
```

Never edit compatibility copies. Rerun setup after changing canonical skills.

Useful flags:

- `--compat` — generate explicit legacy compatibility copies.
- `--local-only` — skip network-backed dependency installation.
- `--skip-pstack` — skip the official pstack installation.
- `--skip-cross-runtime-pstack` — skip the cross-runtime pstack supplement.
- `--skip-matt` — skip selected Matt Pocock skills.

`PSTACK_REF`, `PSTACK_CROSS_REF`, and `MATT_REF` pin upstream refs. Full setup
records resolved commits in `.agent-deps.lock` and keeps source checkouts under
the ignored `.agent-vendor/` directory.

## Upstream workflow dependencies

pstack is not bundled into this plugin. It is the preferred process and
orchestration layer when installed:

```text
pstack
  → workflow, TDD, verification, adversarial review, and proof

agent-engineering-system
  → code-quality and semantic-architecture

host project
  → policy, architecture state, and product constraints
```

The official Cursor pstack plugin is installed separately by `setup.sh` when
enabled. Selected pstack skills are staged into host discovery paths without
becoming canonical root skills.

The cross-runtime [pstack-claude repository](https://github.com/michael-denyer/pstack-claude)
ships a native Claude Code plugin at `plugins/pstack/`. Install that separately
in Claude Code when needed:

```text
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

Its shared skills may still be staged for runtimes that use shared Agent Skills
directories, but this repository's setup no longer copies them into
`.claude/skills/`.

Selected [Matt Pocock skills](https://github.com/mattpocock/skills) remain
upstream specialist dependencies. Setup stages the selected, pinned skills
under `.agents/skills/`; it does not copy them into canonical root `skills/` or
claim ownership of their content. Their provenance and selected names are in
[`docs/UPSTREAM_SKILLS.md`](docs/UPSTREAM_SKILLS.md).

## Editing rules

Edit the source that owns the behavior:

1. Reusable engineering behavior: `skills/<skill-name>/SKILL.md`.
2. Repository operating policy: `.agents/core/AGENT_RULES.md` and
   `.agents/bootstrap.mjs` when generated wording changes.
3. Repository-specific behavior: `.agents/skills/<skill-name>/SKILL.md`.
4. This repository's architecture: `.agents/architecture/`.
5. Packaging, setup, or checks: the manifests, `setup.sh`, `compat/`, or
   `scripts/verify-plugin.sh`.

Do not maintain harness-specific copies of reusable skills. Update the
generator, then regenerate generated adapters:

```bash
node .agents/bootstrap.mjs
```

## Verification

The canonical local check is:

```bash
./scripts/verify-plugin.sh
```

It checks:

- portable Agent Plugins metadata;
- Codex and Claude manifest identity and root skill discovery;
- canonical skill frontmatter and directory names;
- absence of tracked duplicate reusable skills;
- separation of plugin and project-specific skill names;
- current generated adapters;
- repository-local architecture state;
- legacy compatibility outputs when explicitly marked;
- exact coverage of all 82 numbered operating-system sections.

Verification is deterministic and does not require network access.

## Lossless operating-system split

The original 82 numbered operating-system sections remain losslessly mapped:

- repository operating behavior: `.agents/core/AGENT_RULES.md`;
- reusable engineering/design quality: `skills/code-quality/SKILL.md`;
- audit mapping: [`docs/OPERATING_SYSTEM_SPLIT.md`](docs/OPERATING_SYSTEM_SPLIT.md)
  and [`docs/OPERATING_SYSTEM_SPLIT.json`](docs/OPERATING_SYSTEM_SPLIT.json).

Do not compress, summarize, reorganize, or duplicate those rules as part of a
packaging change.

## Versioning and license

The portable plugin version is maintained in `plugin.json` using semantic
versioning. Release notes are in [`CHANGELOG.md`](CHANGELOG.md). The project is
MIT licensed; see [`LICENSE`](LICENSE).

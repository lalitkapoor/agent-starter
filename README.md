# Agent Engineering System

This repository is a reusable Agent Plugins 1.0 package for serious agent-driven software engineering. It publishes portable engineering skills while keeping repository policy, semantic architecture, and project-specific constraints in host-repository state.

## What is portable

The plugin root is the canonical distribution unit:

```text
plugin.json
skills/
├── code-quality/
│   └── SKILL.md
└── semantic-architecture/
    └── SKILL.md
```

`plugin.json` declares the Agent Plugins 1.0 schema. Compatible clients discover skills from the fixed root `skills/` directory; skill paths are intentionally not listed in the manifest.

Agent Plugins 1.0 standardizes portable skills and MCP server configuration. Client-specific agents, hooks, commands, and rules belong in a reverse-domain namespace such as `com.github.copilot/`. This package currently has no client-specific components or MCP server, so those directories are intentionally absent.

See [About GitHub Copilot plugins](https://docs.github.com/en/copilot/concepts/agents/about-plugins) and [Agent plugins in VS Code](https://code.visualstudio.com/docs/agent-customization/agent-plugins) for the current client contract.

## What remains host-repository state

```text
.agents/
├── core/
│   └── AGENT_RULES.md       # detailed repository operating policy
├── architecture/            # this repository's persistent semantic model
├── skills/                  # repository-specific skills only
└── bootstrap.mjs             # generated adapter source
docs/
├── OPERATING_SYSTEM_SPLIT.md
├── OPERATING_SYSTEM_SPLIT.json
└── UPSTREAM_SKILLS.md
compat/                       # compatibility behavior and policy
scripts/verify-plugin.sh      # canonical verification
```

`AGENTS.md` is a short, generated, always-loaded repository contract. It tells an agent to use the installed plugin, pstack when available, repository-local skills, and the relevant architecture path. The complete repository operating policy remains in `.agents/core/AGENT_RULES.md`.

The distinction is intentional:

- `skills/semantic-architecture/` describes how to construct and maintain architectural understanding.
- `.agents/architecture/` records what this particular repository means.
- `skills/code-quality/` contains the detailed reusable engineering quality bar.
- `.agents/skills/` contains only constraints specific to this repository.

Do not package `.agents/architecture/` into a plugin skill or store it in `${PLUGIN_DATA}`. Architectural intent belongs in source control with the host repository.

## Installation and setup

Make the scripts executable once if needed:

```bash
chmod +x setup.sh scripts/*.sh
```

For a local setup with no network access:

```bash
./setup.sh --local-only
```

This regenerates `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and `.cursor/rules/00-project-agents.mdc`, then verifies the plugin.

Native Agent Plugins clients should load this repository directly as a plugin. For a client that cannot load Agent Plugins 1.0 yet, explicitly generate compatibility copies:

```bash
./setup.sh --local-only --compat
```

The compatibility command derives `.cursor/skills/` and `.claude/skills/` from the canonical plugin and host skill trees. These directories are ignored runtime outputs; do not edit or commit them.

A full setup additionally installs separate upstream workflow dependencies:

```bash
./setup.sh
```

Optional flags:

- `--compat` — generate transitional Cursor/Claude skill copies.
- `--local-only` — skip all network-backed dependency installation.
- `--skip-pstack` — do not install official pstack.
- `--skip-cross-runtime-pstack` — do not install the cross-runtime pstack supplement.
- `--skip-matt` — do not install selected Matt Pocock skills.

The `PSTACK_REF`, `PSTACK_CROSS_REF`, and `MATT_REF` environment variables select upstream refs. Setup records resolved commits in `.agent-deps.lock`; vendored checkouts live under the ignored `.agent-vendor/` directory.

## Upstream workflow separation

pstack remains the primary process/orchestration layer when installed. It is not silently folded into this plugin:

```text
pstack
  → process, orchestration, TDD, verification, review, proof

this plugin
  ├── code-quality
  └── semantic-architecture

host repository
  ├── AGENTS.md and .agents/core/
  ├── .agents/architecture/
  └── .agents/skills/
```

Selected Matt Pocock skills remain upstream dependencies. Their exact source and selected names are documented in [`docs/UPSTREAM_SKILLS.md`](docs/UPSTREAM_SKILLS.md); setup records the resolved commit rather than turning their content into plugin-owned source.

## Editing workflow

Change the canonical source for the kind of behavior you are changing:

1. Reusable engineering guidance: edit `skills/<skill-name>/SKILL.md`. Keep skill frontmatter `name` equal to the directory name.
2. Repository-wide agent policy: edit `.agents/core/AGENT_RULES.md` and update the generated contract source in `.agents/bootstrap.mjs` when its short entrypoint needs to change.
3. Repository-specific skill: add or edit `.agents/skills/<skill-name>/SKILL.md`.
4. Repository architectural intent: update the relevant path under `.agents/architecture/`.
5. Compatibility or verification behavior: edit `setup.sh`, `compat/`, or `scripts/verify-plugin.sh`.

Regenerate the adapters after changing policy or generator behavior:

```bash
node .agents/bootstrap.mjs
```

Never hand-edit generated root adapters or compatibility skill copies.

## Verification

Run the canonical check:

```bash
./scripts/verify-plugin.sh
```

It verifies:

- `plugin.json` uses the Agent Plugins 1.0 schema and supported manifest fields;
- portable skills have `SKILL.md` frontmatter whose names match their directories;
- reusable and host skill names do not collide;
- generated adapters are current;
- the host architecture root exists;
- marked compatibility outputs match canonical sources;
- the lossless operating-system mapping still accounts for all 82 numbered sections.

`scripts/verify-agent-setup.sh` remains a compatibility alias for the canonical verifier.

The verifier performs local structural validation of the published schema contract. A network connection is not required for normal verification.

## Versioning

The plugin follows semantic versioning in `plugin.json` and release notes in [`CHANGELOG.md`](CHANGELOG.md):

- PATCH for clarifications and non-semantic fixes;
- MINOR for new compatible skills or capabilities;
- MAJOR for incompatible skill expectations or package-layout changes.

Do not place plugin release history in `.agents/architecture/`; that model describes the current host system, not plugin versions.

## Lossless operating-system split

The original 82 numbered operating-system sections remain losslessly mapped:

- repository operating behavior: `.agents/core/AGENT_RULES.md`;
- reusable engineering/design quality: `skills/code-quality/SKILL.md`;
- audit mapping: [`docs/OPERATING_SYSTEM_SPLIT.md`](docs/OPERATING_SYSTEM_SPLIT.md) and [`docs/OPERATING_SYSTEM_SPLIT.json`](docs/OPERATING_SYSTEM_SPLIT.json).

Do not silently compress or duplicate those rules when evolving the package.

## License

MIT. See [`LICENSE`](LICENSE).

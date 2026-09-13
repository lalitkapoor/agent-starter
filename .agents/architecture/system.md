# Semantic System Model

This repository distributes a reusable multi-harness engineering system while
retaining repository-local policy and architecture state.

## System summary

The root package publishes one canonical skill tree from `skills/`.
Portable Agent Plugins, Codex, and Claude Code metadata wrap that same tree.
Repository policy is generated into `AGENTS.md` from `.agents/` sources.
Persistent architecture knowledge lives under `.agents/architecture/`.
Repository-specific skills live under `.agents/skills/`.
`setup.sh` installs separate upstream workflow dependencies and optional legacy
client compatibility copies.

## Major subsystems

SUBSYSTEM: Portable engineering plugin

RESPONSIBILITIES:
  - Publish reusable engineering skills and their metadata.
  - Provide a stable Agent Plugins 1.0 distribution boundary.

MODEL:
  `plugin.json` and `skills/`

SUBSYSTEM: Native harness packaging

RESPONSIBILITIES:
  - Provide harness-specific metadata without duplicating reusable content.
  - Let each supported runtime discover the canonical root `skills/` tree.

MODEL:
  `.codex-plugin/plugin.json` and `.claude-plugin/plugin.json`

SUBSYSTEM: Repository control plane

RESPONSIBILITIES:
  - Define always-loaded repository policy and generated harness entrypoints.
  - Preserve repository-local architecture and project-specific constraints.

MODEL:
  `.agents/core/`, `.agents/architecture/`, `.agents/skills/`, and generated root adapters

SUBSYSTEM: Installation and compatibility

RESPONSIBILITIES:
  - Install pstack and selected upstream skills as separate dependencies.
  - Materialize legacy client skill copies only when explicitly requested.

MODEL:
  `setup.sh`, `compat/`, and `scripts/verify-plugin.sh`

## System-level relationships

The three plugin manifests IDENTIFY the same root package and `skills/` tree;
no manifest owns a second copy of reusable skill content.
`plugin.json` DISCOVERS `skills/` through the Agent Plugins 1.0 fixed layout.
`.codex-plugin/plugin.json` REFERENCES `./skills/` for Codex's native overlay.
`.claude-plugin/plugin.json` USES the Claude Code default root `skills/` path.
`AGENTS.md` REQUIRES `skills/code-quality/` for non-trivial engineering work.
`AGENTS.md` REQUIRES `skills/semantic-architecture/` for architecture-sensitive work.
`skills/semantic-architecture/` READS `.agents/architecture/`.
`setup.sh` DERIVES legacy compatibility outputs from plugin and host skill sources.

## System-wide sources of truth

DATA: Portable engineering guidance

SOURCE_OF_TRUTH:
  `skills/`

DATA: Repository policy

SOURCE_OF_TRUTH:
  `.agents/core/AGENT_RULES.md` and `.agents/bootstrap.mjs`

DATA: Repository architectural intent

SOURCE_OF_TRUTH:
  `.agents/architecture/`

## System-wide invariants

INVARIANT: PORTABLE_SKILLS_HAVE_ONE_CANONICAL_COPY

STATEMENT:
  Reusable plugin skills are canonical only under root `skills/`; compatibility copies are generated outputs.

INVARIANT: HARNESS_METADATA_DOES_NOT_DUPLICATE_CONTENT

STATEMENT:
  Codex and Claude manifests may differ, but all harnesses discover the same physical root `skills/` files.

INVARIANT: ARCHITECTURE_STATE_IS_HOST_OWNED

STATEMENT:
  `.agents/architecture/` remains repository-local state and is not bundled as a portable skill or plugin data store.

INVARIANT: UPSTREAM_WORKFLOW_IS_SEPARATE

STATEMENT:
  pstack and selected upstream skills remain dependencies installed by setup rather than being silently folded into the engineering plugin.

INVARIANT: LEGACY_COMPATIBILITY_IS_EXPLICIT

STATEMENT:
  `.cursor/skills/` and `.claude/skills/` are generated only as explicit legacy compatibility outputs and are never canonical.

## System boundaries

BOUNDARY: Agent Plugins package

OWNS:
  - `plugin.json`
  - `.codex-plugin/plugin.json`
  - `.claude-plugin/plugin.json`
  - portable `skills/`

DOES_NOT_OWN:
  - repository-specific architecture state
  - generated compatibility copies
  - plugin installation state

## System-level requirements and budgets

REQUIREMENT: OPERATING_SYSTEM_MAPPING

TYPE:
  integrity

TARGET:
  All 82 original numbered sections remain accounted for by `docs/OPERATING_SYSTEM_SPLIT.json`.

## Decisions with system-wide impact

DECISION: ROOT_REPOSITORY_IS_PLUGIN_PACKAGE

STATUS:
  accepted

DECISION:
  This repository's root is the Agent Plugins 1.0 package root because the repository distributes the reusable engineering system.

WHY:
  A consuming product repository should keep only its own policy, architecture, and project skills while installing this package externally.

ALTERNATIVES:
  - Keep the plugin under `.agents/plugins/engineering/`.

CONSEQUENCES:
  - Portable skills are discovered from root `skills/`.
  - `.agents/` remains host-repository support state and is outside the plugin component contract.

SOURCE:
  user-discussed

DECISION: COMPATIBILITY_IS_EXPLICIT

STATUS:
  accepted

DECISION:
  `setup.sh --compat` is required to materialize legacy copies of plugin skills into client-specific skill directories.

WHY:
  Native Codex, Claude Code, and Cursor clients should load the package through
  their native plugin entrypoints, while older or non-plugin clients may still
  need a generated fallback.

CONSEQUENCES:
  - Compatibility directories are ignored runtime outputs.
  - Generated copies are checked against canonical sources when marked by setup.

SOURCE:
  user-discussed

DECISION: HARNESS_MANIFESTS_ARE_THIN_OVERLAYS

STATUS:
  accepted

DECISION:
  Keep portable, Codex-specific, and Claude-specific manifests, but point all
  supported runtimes at the one root `skills/` tree using each runtime's native
  discovery convention.

WHY:
  Agent Plugins 1.0 is portable metadata, while Codex and Claude Code also
  have harness-specific plugin entrypoints. Duplicating skill files would make
  maintenance and verification ambiguous.

ALTERNATIVES:
  - Maintain one copied skill tree per harness.
  - Use only the portable root manifest.

CONSEQUENCES:
  - Manifest identity metadata is repeated intentionally.
  - Reusable skill content is not repeated.
  - Codex marketplace files remain a separate installation/registry concern.

SOURCE:
  user-discussed and external-documentation

DECISION: UPSTREAM_CLAUDE_PSTACK_IS_NATIVE

STATUS:
  accepted

DECISION:
  Do not copy the cross-runtime pstack supplement into `.claude/skills/`;
  use its upstream Claude plugin packaging for Claude and stage shared skills
  only for runtimes that need that discovery path.

WHY:
  The upstream repository ships `plugins/pstack/.claude-plugin/plugin.json`.
  Copying those skills into the host would create a second Claude installation
  path and obscure dependency ownership.

CONSEQUENCES:
  - Claude users install pstack separately through its upstream marketplace.
  - The setup script still pins the upstream checkout and stages shared skills.

SOURCE:
  external-documentation

## Open questions

- Which non-Copilot clients should receive first-class compatibility generators as their plugin support matures?

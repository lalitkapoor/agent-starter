# Semantic System Model

This repository distributes a reusable engineering system as an Agent Plugins
1.0 package while retaining repository-local policy and architecture state.

## System summary

The root package publishes portable skills from `skills/`.
Repository policy is generated into `AGENTS.md` from `.agents/` sources.
Persistent architecture knowledge lives under `.agents/architecture/`.
Repository-specific skills live under `.agents/skills/`.
`setup.sh` installs separate upstream workflow dependencies and optional client compatibility copies.

## Major subsystems

SUBSYSTEM: Portable engineering plugin

RESPONSIBILITIES:
  - Publish reusable engineering skills and their metadata.
  - Provide a stable Agent Plugins 1.0 distribution boundary.

MODEL:
  `plugin.json` and `skills/`

SUBSYSTEM: Repository control plane

RESPONSIBILITIES:
  - Define always-loaded repository policy and generated harness entrypoints.
  - Preserve repository-local architecture and project-specific constraints.

MODEL:
  `.agents/core/`, `.agents/architecture/`, `.agents/skills/`, and generated root adapters

SUBSYSTEM: Installation and compatibility

RESPONSIBILITIES:
  - Install pstack and selected upstream skills as separate dependencies.
  - Materialize client skill copies only when explicitly requested.

MODEL:
  `setup.sh`, `compat/`, and `scripts/verify-plugin.sh`

## System-level relationships

`plugin.json` DISCOVERS `skills/` through the Agent Plugins 1.0 fixed layout.
`AGENTS.md` REQUIRES `skills/code-quality/` for non-trivial engineering work.
`AGENTS.md` REQUIRES `skills/semantic-architecture/` for architecture-sensitive work.
`skills/semantic-architecture/` READS `.agents/architecture/`.
`setup.sh` DERIVES compatibility outputs from plugin and host skill sources.

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

INVARIANT: ARCHITECTURE_STATE_IS_HOST_OWNED

STATEMENT:
  `.agents/architecture/` remains repository-local state and is not bundled as a portable skill or plugin data store.

INVARIANT: UPSTREAM_WORKFLOW_IS_SEPARATE

STATEMENT:
  pstack and selected upstream skills remain dependencies installed by setup rather than being silently folded into the engineering plugin.

## System boundaries

BOUNDARY: Agent Plugins package

OWNS:
  - `plugin.json`
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
  `setup.sh --compat` is required to materialize plugin skills into client-specific skill directories.

WHY:
  Native Agent Plugins clients should load the package directly, while transitional clients still need a generated fallback.

CONSEQUENCES:
  - Compatibility directories are ignored runtime outputs.
  - Generated copies are checked against canonical sources when marked by setup.

SOURCE:
  user-discussed

## Open questions

- Which non-Copilot clients should receive first-class compatibility generators as their plugin support matures?

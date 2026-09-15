# agent-starter Architecture

This repository is a curated catalog and installer for coding-agent plugins. It
maintains one engineering plugin and selects additional upstream plugins or
skills for installation into a consuming project.

## System summary

`catalog.json` is the canonical list of offerings and their provenance. Custom
plugin packages maintained by this repository live under `plugins/`. The
maintained `agent-engineering-system` plugin has one canonical skill tree under
`plugins/agent-engineering-system/skills/`.

The root `.claude-plugin/marketplace.json` and
`.agents/plugins/marketplace.json` are generated native catalog views. They are
installation indexes, not alternate homes for plugin content.

Repository policy is generated into `AGENTS.md` from `.agents/` sources.
This file is the catalog's cross-cutting architecture model. A consuming project
keeps its own policy, colocated architecture documents, and project-specific
skills.

## Major subsystems

SUBSYSTEM: Curated catalog

RESPONSIBILITIES:
  - List maintained plugins and selected upstream dependencies.
  - Record ownership, provenance, upstream refs, and runtime installation routes.
  - Provide one input from which native catalog views can be generated.

MODEL:
  `catalog.json`

SUBSYSTEM: Maintained engineering plugin

RESPONSIBILITIES:
  - Publish the engineering quality, semantic architecture, and technical communication skills maintained here.
  - Keep reusable skill content in one physical tree.

MODEL:
  `plugins/agent-engineering-system/`

SUBSYSTEM: Native catalog adapters

RESPONSIBILITIES:
  - Expose catalog entries using the native marketplace format for each supported runtime.
  - Keep runtime metadata separate from plugin content.

MODEL:
  `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`

SUBSYSTEM: Repository control plane

RESPONSIBILITIES:
  - Define always-loaded policy and generated repository instruction adapters.
  - Preserve this repository's architecture state and maintenance skills.

MODEL:
  `AGENTS.md`, `ARCHITECTURE.md`, `.agents/core/`, `.agents/skills/`, and
  generated root adapters

SUBSYSTEM: Project installer

RESPONSIBILITIES:
  - Configure a consuming project's instruction entrypoints.
  - Install the maintained plugin and selected upstream offerings through native routes.
  - Use `npx skills` only where a runtime has a skill-only route or explicit legacy compatibility was requested.

MODEL:
  `setup.sh` and `scripts/setup-project.mjs`

## System-level relationships

`catalog.json` SELECTS `agent-engineering-system`, pstack, HumanLayer's
`show-me`, and selected Matt Pocock skills as separate offerings.
`plugins/agent-engineering-system/` OWNS the three maintained engineering skills.
The generated Claude and Codex marketplace files ADVERTISE catalog entries;
they do not copy or own skill content.
`setup.sh` READS the catalog through `scripts/setup-project.mjs` and routes each
entry according to its runtime definition.
`AGENTS.md` REQUIRES the maintained code-quality skill for non-trivial work,
the semantic-architecture skill for architecture-sensitive work, and the
technical-communication skill for engineering writing.
`technical-communication` APPLIES to comments, commits, pull requests,
documentation, RFCs, architecture diagrams, specifications, and handoffs.
`semantic-architecture` READS the nearest `ARCHITECTURE.md` for each affected
subsystem in a consuming repository rather than this catalog's state when
installed there.

## System-wide sources of truth

DATA: Curated offerings and installation routes

SOURCE_OF_TRUTH:
  `catalog.json`

DATA: Maintained engineering guidance

SOURCE_OF_TRUTH:
  `plugins/agent-engineering-system/skills/`

DATA: Repository policy

SOURCE_OF_TRUTH:
  `.agents/core/AGENT_RULES.md` and `.agents/bootstrap.mjs`

DATA: Repository architectural intent

SOURCE_OF_TRUTH:
  `ARCHITECTURE.md`

## System-wide invariants

### INV-0001 — Maintained plugin skills have one canonical copy

- **Statement:** Reusable skills maintained by this repository exist only under
  their plugin's canonical `skills/` tree. Harness metadata and compatibility
  output never become a second source.

### INV-0002 — Catalog views are derived

- **Statement:** Native marketplace files are generated from `catalog.json` and
  must not be hand-maintained independently.

### INV-0003 — Upstream content remains external

- **Statement:** Upstream plugin and skill offerings remain external
  dependencies. This repository records how to install them but does not copy
  them into its maintained plugin.

### INV-0004 — Upstream dependencies are not commit-pinned

- **Statement:** The catalog records upstream repositories and declared refs
  such as `main`, but does not lock offerings to commit SHAs or vendor their
  source.

### INV-0005 — Project state is host-owned

- **Statement:** A consuming project's `AGENTS.md`, colocated
  `ARCHITECTURE.md` files, and `.agents/skills/` remain owned by that project.
  The installer may add a marked integration block but must not overwrite
  surrounding content.

### INV-0006 — Legacy compatibility is explicit

- **Statement:** Skill-only copies under `.agents/skills/`, `.claude/skills/`,
  or `.cursor/skills/` are fallback outputs from an explicit compatibility
  path; they are never canonical plugin content.

## System boundaries

BOUNDARY: Maintained plugin package

OWNS:
  - `plugins/agent-engineering-system/plugin.json`
  - `plugins/agent-engineering-system/.codex-plugin/plugin.json`
  - `plugins/agent-engineering-system/.claude-plugin/plugin.json`
  - `plugins/agent-engineering-system/skills/`

DOES_NOT_OWN:
  - `catalog.json` entries for upstream projects
  - consuming-project architecture state
  - generated marketplace indexes
  - installed plugin state

BOUNDARY: Curated catalog

OWNS:
  - the selected set of offerings
  - runtime-specific source and installation metadata
  - generated native marketplace views

DOES_NOT_OWN:
  - upstream skill or plugin source code
  - a consuming project's product instructions

## System-level requirements and budgets

REQUIREMENT: INSTALLER_MUST_BE_SAFE_TO_REAPPLY

TYPE:
  behavior

TARGET:
  Re-running setup updates only the marked instruction block and explicitly
  managed plugin destinations; it does not overwrite surrounding project policy.

## Decisions with system-wide impact

DECISION: ROOT_REPOSITORY_IS_CURATED_DISTRIBUTION

STATUS:
  accepted

DECISION:
  The repository root is the catalog and installer. Maintained plugin packages
  are explicit children under `plugins/`; the root is not itself one plugin
  package.

WHY:
  The repository maintains a curated set containing its own engineering plugin
  plus separate upstream offerings. Treating the root as one plugin obscures
  selection, provenance, and installation differences.

ALTERNATIVES:
  - Treat the entire repository as the agent-engineering-system plugin.
  - Keep maintained plugin content under `.agents/plugins/`.

CONSEQUENCES:
  - `catalog.json` is the root distribution contract.
  - `.agents/plugins/marketplace.json` is a generated Codex catalog view, not a package directory.
  - Consuming projects can install one maintained plugin or the curated set.

SOURCE:
  user-discussed

DECISION: ARCHITECTURE_DOCUMENTS_ARE_COLOCATED

STATUS:
  accepted

DECISION:
  Consuming projects store semantic architecture in `ARCHITECTURE.md` files
  beside the meaningful subsystems they describe. A repository-root
  `ARCHITECTURE.md` is reserved for genuinely system-wide relationships and
  guarantees.

WHY:
  Agents can discover the nearest architecture document from the files they
  are changing, and the model remains close to the implementation it describes.

CONSEQUENCES:
  - `setup.sh` establishes the discovery rule but does not create architecture
    files or a project-level architecture directory.
  - Agents create a document only when a subsystem has meaningful independent
    semantics; they do not create one for every source file.
  - This catalog keeps its own cross-cutting model in the root `ARCHITECTURE.md`.

SOURCE:
  user-discussed

DECISION: CATALOG_VIEWS_ARE_GENERATED

STATUS:
  accepted

DECISION:
  Generate Claude and Codex marketplace files from `catalog.json` with
  `.agents/bootstrap.mjs`.

WHY:
  Each runtime has a different marketplace shape, but the curated selection
  and provenance should have one source of truth.

CONSEQUENCES:
  - Add or remove an offering in `catalog.json`, then regenerate.
  - Review generated marketplace changes as derived metadata.

SOURCE:
  user-discussed and external-documentation

DECISION: UPSTREAM_DEPENDENCIES_USE_DECLARED_REFS

STATUS:
  accepted

DECISION:
  Follow the repository/ref declared for each upstream offering rather than
  storing a commit SHA in the catalog.

WHY:
  The catalog is a curated selection and installation policy, not a lockfile.
  Upstream projects remain responsible for their own releases, and the user
  wants installations to follow those upstream refs.

CONSEQUENCES:
  - A later installation can receive newer upstream changes.
  - Verification rejects accidental SHA pins.
  - Reproducibility would require a separate, explicit lockfile policy later.

SOURCE:
  user-request

DECISION: NATIVE_INSTALLATION_WITH_SKILL_FALLBACK

STATUS:
  accepted

DECISION:
  `setup.sh` uses native plugin installation for Claude and Codex, copies the
  maintained plugin and upstream Cursor plugin into Cursor's local plugin
  directory, and uses `npx skills` for upstream skill-only routes or explicit
  legacy compatibility.

WHY:
  A skill installer can distribute skill files but cannot replace native plugin
  registration, plugin metadata, or upstream plugin lifecycle behavior.

CONSEQUENCES:
  - Native plugin installation is the normal path.
  - `--compat` is deliberately visible and optional.
  - Upstream pstack, HumanLayer, and Matt sources remain separate from
    maintained content.

SOURCE:
  user-discussed and external-documentation

DECISION: TECHNICAL_COMMUNICATION_IS_A_MAINTAINED_SKILL

STATUS:
  accepted

DECISION:
  Keep writing guidance as `technical-communication` inside
  `agent-engineering-system` and require it for engineering artifacts.

WHY:
  Comments, commits, PRs, technical documents, RFCs, diagrams, and specs are
  part of the engineering system's quality bar, not a harness-specific adapter.

CONSEQUENCES:
  - The skill is installed with the maintained plugin.
  - `AGENTS.md` and project setup explicitly trigger it for writing work.

SOURCE:
  user-request

## Open questions

- Which additional upstream plugins should be curated after their native
  installation routes and provenance are verified?
- Should the catalog eventually be published from a dedicated marketplace repo,
  separate from this installer and its maintained plugin source?

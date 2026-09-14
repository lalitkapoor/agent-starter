# agent-starter

`agent-starter` is a curated catalog and installer for coding-agent plugins.
It combines one engineering system maintained here with selected upstream
plugins and skills, then installs the right representation for Claude Code,
Codex, Cursor, or another skill-capable runtime.

The important rule is:

> Maintain content once; use catalog and harness metadata to install it where it belongs.

## Start here

From a checkout of this repository, install the curated set into a product
repository with:

```bash
./setup.sh \
  --project /absolute/path/to/my-product \
  --harness claude,codex,cursor
```

This does four things:

1. registers the `agent-starter` marketplace with the selected runtimes;
2. installs the maintained `agent-engineering-system` plugin where the runtime has a CLI install route, or makes it available for selection in Codex;
3. installs offerings through the routes listed in `catalog.json` (Codex gets the catalog registered for selection in its plugin directory);
4. adds a marked integration block to the product's `AGENTS.md` and, when selected, its `CLAUDE.md` or Cursor rule.

The installer does not copy this repository's architecture model into the
product. The product keeps its own architecture state and project-specific
skills.

To see exactly what would happen without changing the product:

```bash
./setup.sh \
  --project /absolute/path/to/my-product \
  --harness claude,codex,cursor \
  --dry-run
```

To install only the maintained plugin from the current checkout:

```bash
./setup.sh \
  --project /absolute/path/to/my-product \
  --harness claude,codex,cursor \
  --local-only \
  --marketplace "$PWD"
```

`--local-only` skips upstream dependencies and uses this checkout as the local
marketplace. It still invokes the selected runtime CLIs when they are included
in `--harness`.

## What this repository contains

The root is intentionally a catalog, not one giant plugin:

```text
agent-starter/
├── catalog.json                              # curated offerings and provenance
├── plugins/
│   └── agent-engineering-system/              # plugin maintained here
│       ├── plugin.json                        # portable plugin manifest
│       ├── .codex-plugin/plugin.json          # Codex metadata
│       ├── .claude-plugin/plugin.json         # Claude metadata
│       └── skills/
│           ├── code-quality/
│           ├── semantic-architecture/
│           └── technical-communication/
├── .claude-plugin/marketplace.json            # generated Claude catalog view
├── .agents/plugins/marketplace.json           # generated Codex catalog view
├── .agents/core/                              # catalog repository policy
├── .agents/architecture/                      # catalog architecture state
├── .agents/skills/                            # catalog-specific skills only
└── setup.sh                                   # consuming-project installer
```

There is no root `plugin.json`, root `skills/`, or root `.codex-plugin/` in the
catalog. Those belong to an individual maintained plugin. The portable
manifest for the maintained plugin is:

```text
plugins/agent-engineering-system/plugin.json
```

This distinction prevents the catalog from confusing its own content with the
upstream dependencies it recommends.

## The three maintained skills

The `agent-engineering-system` plugin is the part of this repository that we
maintain:

| Skill | Use it for |
| --- | --- |
| `code-quality` | Engineering and design rules for non-trivial implementation, debugging, integration, migration, performance, and review work. |
| `semantic-architecture` | Building and maintaining a hierarchical model of a product's responsibilities, ownership, invariants, and relationships. |
| `technical-communication` | Writing comments, commit messages, pull requests, technical documentation, RFCs, architecture diagrams, technical specifications, and handoffs. |

The technical communication skill optimizes for understanding rather than
technical-sounding language. It asks the writer to describe actual behavior,
define terms on first use, make failure modes and ownership explicit, and use
diagrams to show real boundaries and flow.

For example, it prefers:

```text
If the permission check cannot run, reject the request.
```

over:

```text
Fail closed if the permission check is unavailable.
```

The skill is installed with the maintained plugin. The generated `AGENTS.md`
also explicitly tells agents to read it before producing any of those
engineering artifacts.

## Catalog and installation model

`catalog.json` is the single maintained list. It records whether an offering is
maintained here or upstream, its declared source/ref, and the installation
route for each supported runtime.

Upstream offerings intentionally follow declared refs such as `main`; they are
not commit-pinned and are not vendored into this repository. Installing later
may therefore receive newer upstream changes. The catalog is a curated
selection, not a lockfile.

```text
                         catalog.json
                              │
             ┌────────────────┼────────────────┐
             ▼                ▼                ▼
       Claude view       Codex view       Cursor/setup route
  .claude-plugin/     .agents/plugins/     native local plugin
  marketplace.json    marketplace.json    or npx skills fallback
             │                │                │
             └────────────────┼────────────────┘
                              ▼
                 consuming project + AGENTS.md
```

The generated marketplace files are discovery and installation indexes. They
are not a second source of plugin content and should not be edited by hand.
Run `node .agents/bootstrap.mjs` after changing `catalog.json` or generated
instructions.

`.agents/plugins/marketplace.json` exists because Codex uses that location for
a repository-scoped marketplace. It is a registry for the catalog, not the
canonical home of any plugin.

## Curated offerings

### Maintained: `agent-engineering-system`

This plugin is owned by this repository. Its three skills live only under:

```text
plugins/agent-engineering-system/skills/
```

Its native manifests are thin metadata around that same physical tree:

```text
plugins/agent-engineering-system/plugin.json
plugins/agent-engineering-system/.codex-plugin/plugin.json
plugins/agent-engineering-system/.claude-plugin/plugin.json
```

### Upstream: pstack

pstack is a workflow and orchestration dependency, not part of our engineering
plugin. Where installed, agents should use it for the process of doing
non-trivial work: planning, TDD, verification, adversarial review, and proof.

The catalog routes it as follows:

- Claude Code and Codex use the pstack plugin from `michael-denyer/pstack-claude`.
- Cursor uses the official pstack plugin from `cursor/plugins`.

The catalog follows the declared upstream refs when installing. `setup.sh`
installs or fetches those plugins; it never copies them into
`plugins/agent-engineering-system/`.

### Upstream: Matt Pocock's skills

The catalog selects these upstream specialist skills:

```text
codebase-design
domain-modeling
diagnosing-bugs
research
improve-codebase-architecture
code-review
prototype
writing-for-agents
handoff
```

Claude Code installs the upstream `mattpocock-skills` plugin. Codex and Cursor
use the skill-only `npx skills` route for the selected names. That distinction
matters: `npx skills` installs skill files; it does not install a plugin's
other components or lifecycle behavior.

Upstream provenance and the selected names are recorded in
[`docs/UPSTREAM_SKILLS.md`](docs/UPSTREAM_SKILLS.md).

## Using it with an actual product repository

The product repository is where product policy and semantic understanding live.
After setup, its shape should be conceptually similar to:

```text
my-product/
├── AGENTS.md                          # product contract + Agent Starter block
├── CLAUDE.md                          # thin Claude adapter, if selected
├── .cursor/rules/00-agent-starter.mdc # thin Cursor adapter, if selected
├── .agents/
│   ├── architecture/
│   │   └── system.md                  # what this product means
│   └── skills/
│       └── product-specific-skill/
└── src/
```

The generated Agent Starter block is bounded by markers:

```md
<!-- BEGIN AGENT-STARTER -->
## Agent Starter

- Use the `agent-engineering-system` plugin supplied by the `agent-starter` catalog for `code-quality`, `semantic-architecture`, and `technical-communication`; enable it in the runtime when it is only registered.
- For comments, commit messages, pull requests, technical documentation, RFCs, architecture diagrams, technical specifications, and other engineering writing, read the complete `technical-communication` skill before drafting.
- Use pstack as the primary workflow for non-trivial engineering work when it is installed.
<!-- END AGENT-STARTER -->
```

Setup updates only this marked block. It preserves the surrounding product
instructions. The product should add its own architecture model under
`.agents/architecture/` rather than copying this catalog's
`.agents/architecture/`.

During a non-trivial change, an agent combines:

```text
product AGENTS.md
  + installed agent-engineering-system plugin
  + product .agents/architecture/
  + product .agents/skills/
  + pstack, when installed
  + selected upstream specialist skills
```

The maintained `semantic-architecture` skill explains how to update the model;
the product's `.agents/architecture/` files record the model itself. The
maintained `technical-communication` skill explains how to communicate the
result in code comments, commits, PRs, RFCs, diagrams, and specifications.

## Native runtime routes

`setup.sh` is the convenient curated installer. These are the equivalent native
routes when you want to manage a runtime directly.

### Claude Code

Add the marketplace and install the offerings you want:

```bash
claude plugin marketplace add lalitkapoor/agent-starter --scope project
claude plugin install agent-engineering-system@agent-starter --scope project
claude plugin install pstack@agent-starter --scope project
claude plugin install mattpocock-skills@agent-starter --scope project
```

Or use the corresponding `/plugin marketplace add` and `/plugin install`
commands inside Claude Code. Claude discovers each plugin's `skills/` directory
relative to that plugin root and namespaces its skills.

### Codex

Register the repository-scoped marketplace:

```bash
codex plugin marketplace add lalitkapoor/agent-starter
```

Then enable `agent-engineering-system` and, if wanted, `pstack` from the Codex
plugin directory. In Codex surfaces that support repository configuration, the
corresponding entries use the `plugin-name@agent-starter` keys, for example:

```toml
[plugins."agent-engineering-system@agent-starter"]
enabled = true

[plugins."pstack@agent-starter"]
enabled = true
```

The current Codex CLI documents marketplace registration and plugin-directory
selection separately; `setup.sh` follows that boundary rather than inventing a
second install command.

Matt Pocock's selected entries are skills rather than a Codex plugin route:

```bash
npx skills@latest add mattpocock/skills \
  --skill codebase-design \
  --agent codex \
  -y
```

Repeat the command for the other selected names, or let `setup.sh` do it.

### Cursor

Cursor's local plugin route uses the plugin directory under the user's Cursor
configuration. `setup.sh` copies the maintained plugin there from the checkout
and fetches the official pstack plugin from its declared ref. For Matt Pocock's skill-only
entries it uses `npx skills` with `--agent cursor`.

If you are testing only the maintained plugin locally:

```bash
mkdir -p ~/.cursor/plugins/local
cp -R plugins/agent-engineering-system ~/.cursor/plugins/local/agent-engineering-system
```

Restart or reload Cursor after changing a local plugin.

### Other runtimes

The maintained plugin has a portable `plugin.json` and a standard root
`skills/` directory. A runtime that supports portable Agent Plugins can load:

```text
plugins/agent-engineering-system/
```

If a runtime supports only skill directories, use `npx skills` or the runtime's
documented skill installation mechanism. The result is skill-only compatibility,
not a replacement for native plugin installation.

## `AGENTS.md` responsibilities

There are two different `AGENTS.md` roles:

1. This repository's root `AGENTS.md` governs maintenance of the catalog,
   installer, maintained plugin, and generated views.
2. A consuming product's root `AGENTS.md` governs that product. `setup.sh`
   adds a small managed block to it; it does not replace the product contract.

The Agent Starter block requires agents to:

- use `code-quality` for substantial engineering work;
- use `semantic-architecture` when product architecture or system semantics may change;
- use `technical-communication` for comments, commit messages, PRs, technical documentation, RFCs, architecture diagrams, technical specifications, and other engineering writing;
- use pstack as the primary workflow when available;
- keep product architecture state and project-specific skills in the product repository.

`AGENTS.md` is policy. It is not a replacement for the installed skills, and it
does not contain the product's architecture model.

## Legacy compatibility

Native plugin installation is the normal path. If a client cannot load a native
plugin, pass `--compat` explicitly:

```bash
./setup.sh \
  --project /absolute/path/to/my-product \
  --harness claude,codex,cursor \
  --compat
```

This materializes generated skill-only outputs in the consuming project. Do not
edit those outputs or commit them as canonical content. Upstream skill-only
entries still use `npx skills` on runtimes that do not have a native plugin
route.

## Maintaining the catalog

When adding or changing a maintained plugin:

1. add or edit the plugin under `plugins/`;
2. keep its reusable skills in one plugin-local `skills/` tree;
3. add its selection and runtime routes to `catalog.json`;
4. run `node .agents/bootstrap.mjs` to regenerate marketplace views and root adapters;
5. run `./scripts/verify-catalog.sh` and inspect the diff.

When updating an upstream dependency:

1. inspect the upstream repository and its current native packaging;
2. update its repository/ref and installation route in `catalog.json`;
3. regenerate the derived views;
4. update [`docs/UPSTREAM_SKILLS.md`](docs/UPSTREAM_SKILLS.md) if the route or selected set changes;
5. verify that no upstream files were copied into the maintained plugin.

Do not add upstream skills to `plugins/agent-engineering-system/skills/`.
Do not create `.agents/plugins/marketplace.json` entries by hand. Do not add a
new harness-specific copy unless the runtime truly needs an adapter that the
portable package cannot provide.

## Verification

Run the local checks before committing:

```bash
node .agents/bootstrap.mjs
./scripts/verify-catalog.sh
./scripts/verify-plugin.sh
git diff --check
```

The verifier checks:

- catalog identity, ownership, provenance, and runtime routes;
- the maintained portable, Codex, and Claude manifests;
- the one canonical maintained skill tree and matching skill frontmatter;
- generated Claude and Codex marketplace views;
- generated adapters and the technical communication trigger in `AGENTS.md`;
- absence of committed duplicate maintained skills;
- the 82 original operating-system sections exactly once.

The checks are local-only. They do not claim that a live Claude, Codex, Cursor,
GitHub, or upstream installation succeeded. Exercise those runtime boundaries
separately when changing installation behavior.

## References

- [OpenAI: Package your plugin](https://developers.openai.com/plugins/build/plugins)
- [Claude Code: Create and distribute a plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
- [Claude Code: Plugins](https://code.claude.com/docs/en/plugins)
- [Cursor: Plugins](https://cursor.com/docs/plugins)
- [Vercel Labs: `skills` installer](https://github.com/vercel-labs/skills)
- [pstack](https://github.com/michael-denyer/pstack-claude)
- [Matt Pocock's skills](https://github.com/mattpocock/skills)

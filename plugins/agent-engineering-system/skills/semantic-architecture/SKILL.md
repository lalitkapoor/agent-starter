---
name: semantic-architecture
description: Maintains a hierarchical semantic model of system responsibilities, ownership, relationships, invariants, and architectural decisions.
---

# Skill: Semantic Architecture

Use for a new system, feature, subsystem, significant refactor, or architectural change.

The goal is a persistent, hierarchical semantic model so future agents can understand the system at the right level without reconstructing intent from source code.

## Core model

Architecture is hierarchical but conceptually one graph:

```text
system
  ↓
subsystem
  ↓
component
  ↓
implementation
```

The filesystem is storage. Relationships may cross files and subsystem boundaries.

## Inspect before asking

Before implementation:
- inspect the root model,
- follow the relevant child architecture path,
- inspect implementation,
- inspect tests/schemas/traces/design records,
- determine what is already knowable,
- identify only unresolved choices that materially affect architecture.

Do not ask questions whose answers are confidently derivable.

## Ask design questions before substantial implementation

Group questions and classify them:
- `REQUIRED` — cannot safely proceed without an answer
- `IMPORTANT` — a default exists but materially changes design
- `OPTIONAL` — useful but not blocking

Prioritize behavior, ownership, boundaries, source of truth, lifecycle, consistency, failure behavior, concurrency, persistence, caching/invalidation, performance, security/privacy, offline behavior, compatibility/migration, acceptable complexity, and non-goals.

## Create hierarchy only where semantics justify it

Root:
`.agents/architecture/system.md`

Example:
```text
.agents/architecture/
├── system.md
├── editor/
│   ├── system.md
│   └── rendering/
│       └── system.md
├── sync/
│   ├── system.md
│   └── replication/
│       └── system.md
└── navigation/
    └── system.md
```

Create a deeper model when there is distinct ownership, local invariants, important internal relationships, local lifecycle/source-of-truth rules, repeated rediscovery cost, or an overloaded parent model.

Do not recreate the source tree.

## Place facts at the lowest meaningful level

A fact belongs at the lowest scope where it is architecturally meaningful, and no lower.

Do not duplicate facts across levels unless the higher-level version is a useful summary.

## Progressive disclosure

### System
Ask:
- what broad responsibilities constrain this?
- what system-wide invariants apply?
- what cross-subsystem boundaries matter?

### Subsystem
Ask:
- what owns what?
- what relationships constrain this?
- what source-of-truth/lifecycle rules apply?

### Component
Ask:
- what local invariants apply?
- what may this read/write/invalidate/emit/own?
- what effects or errors escape the interface?

### Implementation
Ask:
- what does the code actually do today?

Do not load unrelated architecture branches by default.

## Components

Example:
```text
COMPONENT: PageCache

TYPE:
  cache

RESPONSIBILITIES:
  - provide immediately available page snapshots

OWNS:
  - cached PageSnapshot

DOES_NOT_OWN:
  - canonical Page state

INVALIDATED_BY:
  - PageMutation

SOURCE_OF_TRUTH:
  false

CONSISTENCY:
  eventual
```

Only include fields with semantic value.

## Typed relationships

Example:
```text
Navigation
  REQUIRES -> PageAvailable

PageLoader
  PROVIDES -> PageAvailable
  READS -> PageCache
  FALLS_BACK_TO -> PageAPI

PageMutation
  WRITES -> PageAPI
  MUST_INVALIDATE -> PageCache
```

Useful verbs:
`OWNS`, `READS`, `WRITES`, `CALLS`, `PROVIDES`, `REQUIRES`, `DEPENDS_ON`,
`INVALIDATES`, `MUST_INVALIDATE`, `PRODUCES`, `CONSUMES`, `EMITS`,
`SUBSCRIBES_TO`, `FALLS_BACK_TO`, `SYNCHRONIZES_WITH`, `AUTHORIZES`,
`GOVERNS`, `PERSISTS_TO`, `DERIVED_FROM`.

## Invariants

Represent each invariant with a stable four-digit `INV-0000` identifier in its
heading and bulleted fields so adjacent invariants are visually distinct. Use
the next unused identifier; do not reuse an identifier for a different
invariant.

Example:

### INV-0001 — Page cache is not the source of truth

- **Statement:** PageCache must never become canonical Page state.
- **Applies to:** `PageCache`, `PageLoader`, `PageMutation`
- **Rationale:** Cached state may be stale and replaceable by canonical state.
- **Validated by:** `page-cache-invalidation.test.ts`

Local invariants are first-class too.

## Sources of truth

Example:
```text
DATA: Page

SOURCE_OF_TRUTH:
  PageStore

DERIVED:
  - PageCache
  - SearchIndex

SYNCHRONIZATION:
  PageMutation updates PageStore and invalidates dependent representations.
```

## Boundaries and ownership

Example:
```text
BOUNDARY: PagePersistence

OWNS:
  - serialized Page records
  - persistence migrations

ALLOWED_DEPENDENCIES:
  - StorageEngine

FORBIDDEN_DEPENDENCIES:
  - NavigationUI
```

Prefer constraints that could eventually be checked mechanically.

## Requirements and budgets

Example:
```text
REQUIREMENT: PAGE_NAVIGATION_LATENCY

TYPE:
  performance

TARGET:
  p95 < 100ms

APPLIES_TO:
  Navigation -> PageAvailable
```

Never invent numerical targets.

## Decisions

Record decisions only when multiple reasonable alternatives existed or future agents could plausibly revisit the choice.

```text
DECISION: CACHE_RECONCILIATION_STRATEGY

STATUS:
  accepted

DECISION:
  Return cached Page immediately and reconcile asynchronously.

WHY:
  Navigation latency is more important than immediate consistency.

ALTERNATIVES:
  - wait for canonical state
  - do not cache

CONSEQUENCES:
  - stale state may temporarily render
  - mutations require reliable invalidation

SOURCE:
  user-discussed
```

Sources:
`user-discussed`, `existing-architecture`, `implementation-discovery`, `agent-decision`.

## Decisions discovered during implementation

When a meaningful architectural choice becomes necessary but was not discussed:
1. choose the best reasonable path needed to continue,
2. record it at the lowest relevant level,
3. mark its source,
4. capture alternatives/rationale when useful,
5. surface it at completion,
6. propagate broader implications upward if needed.

## Evidence

Attach evidence when useful:
```text
RELATIONSHIP:
  PageMutation MUST_INVALIDATE PageCache

EVIDENCE:
  - TYPE: test
    REF: page-mutation.test.ts
  - TYPE: source-code
    REF: PageMutation.invalidate()
```

Evidence types:
`static-analysis`, `type-system`, `runtime-trace`, `test`, `telemetry`,
`schema`, `source-code`, `design-document`, `user-statement`, `agent-inference`.

For uncertain facts:
`CONFIDENCE: low | medium | high`.

## Semantic delta before implementation

Example:
```text
SEMANTIC DELTA

ADD:
  PagePreloader PRELOADS PageCache

PRESERVE:
  - system: Navigation does not wait for reconciliation
  - navigation: PageLoader remains responsible for PageAvailable
  - cache: PageCache is not source of truth
  - mutation: PageMutation must invalidate PageCache

REMOVE:
  - none
```

This describes the intended system change independently of files/syntax.

## Implement against the model

Before modifying a significant component, establish:
- ownership,
- dependencies,
- dependents,
- parent constraints,
- local invariants,
- state reads/writes,
- what must remain true.

Then implement, test, compare against semantic delta, capture discoveries, and revert or record unexpected semantic changes.

## Zoom back out

For every discovery:
1. implementation-only? do not add to architecture.
2. local architecture? record in nearest model.
3. constrains siblings? summarize at parent.
4. changes system-wide guarantee? propagate to root.

Example:
```text
RetryScheduler MAY_REORDER mutations across different pages
```

may imply:
```text
Sync
  GUARANTEES_ORDERING -> PerPage
  DOES_NOT_GUARANTEE_ORDERING -> Global
```

## Cross-level consistency

Parent and child models must not contradict each other.

Update a parent only when a child discovery invalidates a parent fact, makes it misleading, or introduces a broader constraint.

Higher levels summarize; they do not duplicate lower-level implementation semantics.

## Keep current

Update semantic architecture when responsibilities, ownership, boundaries, data flow, source of truth, consistency, lifecycle, important dependencies, invariants, requirements, or architectural decisions change.

Do not update for implementation-only changes that preserve semantics.

Git is history. The architecture tree describes the current system.

## Avoid two failure modes

Too coarse: one giant `system.md`.

Too granular: source-tree-shaped documentation.

Target **semantic compression**: preserve facts future agents would otherwise need to reason about or rediscover.

## Completion report

For significant work, report:
```text
IMPLEMENTED
SEMANTIC DELTA
INVARIANTS
DISCOVERIES
PROPAGATED INSIGHTS
AGENT DECISIONS
MODEL UPDATES
OPEN QUESTIONS
```

The persistent architecture artifacts are the record.

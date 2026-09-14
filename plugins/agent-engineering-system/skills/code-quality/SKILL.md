---
name: code-quality
description: Detailed engineering quality and design rules for non-trivial implementation, refactors, debugging, integration, and migration work.
---

# Skill: Code Quality

Use this skill for any non-trivial implementation, refactor, debugging task, integration change,
performance work, migration, concurrency change, persistence change, or substantial review.

Read this skill completely before substantial implementation. Then apply the sections relevant to the task.

This skill contains engineering/design quality rules only. Repository-wide operating behavior such as
instruction precedence, completion discipline, source-control workflow, evidence claims, and handoff rules
lives in `.agents/core/AGENT_RULES.md`.

When pstack is available:
- pstack owns engineering process/orchestration;
- this skill owns the detailed engineering/design quality bar;
- semantic-architecture owns persistent capture of architectural intent.

The section headings below use local numbering from 1 through 53 so this skill
reads as a complete document.

# 1. Model the Domain Before the Framework

Identify the concepts involved before writing framework glue.

Look for:

- entities;
- value objects;
- state transitions;
- commands;
- queries;
- invariants;
- ownership;
- effects;
- error categories.

Prefer project-owned domain types over loosely structured bags of framework data.

Example:

```ts
type InvitationStatus =
  | { type: "pending"; expiresAt: Date }
  | { type: "accepted"; acceptedAt: Date }
  | { type: "expired" }

```

rather than combinations of unrelated booleans:

```ts
{
  accepted: boolean
  expired: boolean
  pending: boolean
}

```

Use the type system to make impossible states difficult or impossible to represent.

Do not create domain types that merely rename primitives without adding meaning, constraints, or clarity.

---

---

# 2. Build Deep Modules

Prefer modules with:

```text
small, stable interface
        ↓
substantial cohesive behavior

```

over:

```text
many small interfaces
→ many thin wrappers
→ many forwarding layers
→ unclear responsibility

```

A good module:

- owns a coherent responsibility;
- hides implementation details;
- exposes a small contract;
- can be reasoned about locally;
- can change internally without forcing unrelated callers to change.

Do not maximize:

- number of interfaces;
- number of files;
- number of classes;
- number of layers.

Abstraction has a cost.

Every abstraction should reduce complexity somewhere else.

---

---

# 3. Use Interfaces at Real Seams

Introduce interfaces or protocols when they separate genuine replacement or effect boundaries.

Good candidates:

- persistence;
- external APIs;
- network transports;
- clocks;
- randomness;
- email;
- payments;
- queues;
- filesystem;
- browser/runtime boundaries;
- model providers;
- infrastructure owned outside the module.

Poor candidates:

- every helper function;
- every class solely to allow mocking;
- one-to-one forwarding wrappers with no semantic boundary;
- speculative future provider replacement.

Do not confuse testability with interface proliferation.

If an implementation is deterministic and local, test it directly.

---

---

# 4. Keep Dependency Direction Clear

A healthy dependency shape is usually:

```text
UI / HTTP / framework
        ↓
application orchestration
        ↓
domain
        ↓
effect contracts

external provider SDK
        ↓
adapter
        ↓
project-owned values

```

Domain and application logic should generally not depend directly on:

- React components;
- Express/Fastify request objects;
- ORM-specific row types;
- Stripe/OpenAI/AWS/etc. SDK types;
- analytics SDKs;
- transport-specific message objects.

Translate at boundaries.

---

---

# 5. Provider Types Stop at Adapters

Third-party SDK types should not become your application’s domain language.

Bad:

```ts
async function decideRenewal(
  subscription: Stripe.Subscription
): Promise<RenewalDecision>

```

Better:

```ts
interface SubscriptionSnapshot {
  id: SubscriptionId
  status: SubscriptionStatus
  renewalDate: Date | null
}

```

The adapter is responsible for converting provider data into project-owned values.

This applies to:

- databases;
- payment systems;
- auth providers;
- APIs;
- cloud SDKs;
- message queues;
- model providers;
- analytics;
- browser APIs;
- framework request/response types.

This containment makes provider changes, SDK upgrades, testing, and refactoring substantially safer.

---

---

# 6. TypeScript Is Not Runtime Validation

TypeScript protects compiled code from many developer mistakes.

It does not validate runtime data.

All untrusted boundary data must be validated.

Examples:

- HTTP payloads;
- route parameters;
- environment variables;
- webhook bodies;
- queue messages;
- third-party API responses;
- database values when the database schema does not fully guarantee the shape;
- deserialized files;
- user input;
- model-generated structured output.

Preferred flow:

```text
unknown external value
        ↓
runtime schema validation
        ↓
project-owned typed value
        ↓
application/domain logic

```

Use the repository’s established validation library when available.

Do not use:

```ts
value as SomeType

```

as a substitute for runtime validation.

---

---

# 7. Avoid `any`

`any` turns off the compiler.

Prefer:

- `unknown`;
- generics;
- discriminated unions;
- narrow boundary adapters;
- validated project-owned types.

If an unavoidable untyped dependency requires `any`, contain it within the smallest possible adapter and convert immediately to safe types.

Do not spread `any` into application or domain code.

Do not weaken types merely to get the build passing.

---

---

# 8. Make Invalid States Hard to Represent

Prefer discriminated unions and explicit state machines over loosely related flags.

Example:

```ts
type UploadState =
  | { type: "idle" }
  | { type: "uploading"; startedAt: number }
  | { type: "failed"; error: UploadError }
  | { type: "complete"; assetId: AssetId }

```

This is usually safer than:

```ts
{
  isUploading: boolean
  didFail: boolean
  isComplete: boolean
}

```

Ask:

> What combinations of state are actually legal?

Encode that answer into the model.

---

---

# 9. Mutable State Must Have an Owner

Every important mutable resource needs one identifiable owner.

Examples:

- cache;
- websocket;
- background worker;
- queue consumer;
- database transaction;
- mutable document;
- in-memory registry;
- subscription collection;
- long-lived browser/session state.

Avoid architectures where multiple unrelated modules can independently mutate the same resource.

Prefer:

```text
one owner
    ↓
explicit commands
    ↓
readers / observers

```

Shared mutation creates hidden coupling.

---

---

# 10. Async Work Must Have a Lifetime

For every long-running operation, know:

- who starts it;
- who owns it;
- how it is cancelled;
- whether it can run twice;
- how failure is surfaced;
- who cleans it up;
- what happens during shutdown.

Use tools such as:

- `AbortSignal`;
- explicit lifecycle objects;
- `try/finally`;
- framework cleanup primitives;
- bounded scopes.

Do not leave behind:

- orphan promises;
- timers;
- listeners;
- sockets;
- subscriptions;
- workers;
- polling loops.

Lifecycle behavior is part of correctness.

---

---

# 11. Concurrency Must Be Intentional

Do not accidentally create unlimited concurrency.

For concurrent work, explicitly consider:

- ordering;
- cancellation;
- idempotency;
- conflict behavior;
- retries;
- rate limits;
- resource bounds.

Be careful with:

```ts
await Promise.all(items.map(processItem))

```

when `items` may be unbounded or `processItem` has external effects.

Use bounded concurrency where appropriate.

---

---

# 12. Side Effects Belong at Clear Edges

Separate decision-making from execution where doing so improves clarity.

Prefer:

```text
validated input
      ↓
decision / transformation
      ↓
explicit effect

```

Example:

```ts
const decision = decideRefund(order, policy)

await refundExecutor.execute(decision)

```

This is particularly valuable for:

- payments;
- emails;
- database mutation;
- file writes;
- external APIs;
- scheduling;
- destructive operations;
- irreversible actions.

The module that decides **what should happen** does not always need to own **how the outside world is changed**.

---

---

# 13. Keep Orchestration Thin

Coordinators should connect modules rather than absorb their algorithms.

Good:

```text
load
→ validate
→ invoke domain operation
→ execute effect
→ return result

```

Warning sign:

A large “service” that:

- parses data;
- implements business rules;
- queries storage;
- calls several providers;
- manages retries;
- owns caching;
- formats UI output;
- controls concurrency.

When orchestration becomes algorithmic, move cohesive behavior into the module that owns it.

---

---

# 14. Validate at Boundaries and Trust Internally

Validate invariants where data enters the trusted system.

Once converted to a valid project-owned type, internal modules should generally be able to trust those invariants.

Avoid repeatedly validating the same condition throughout the call graph.

This improves:

- readability;
- performance;
- responsibility clarity.

Validation should belong somewhere specific.

---

---

# 15. Treat Errors as Part of the Contract

Do not rely on arbitrary strings or raw provider exceptions as application behavior.

Represent meaningful failures explicitly.

Example:

```ts
type CreateAccountError =
  | { type: "email_taken" }
  | { type: "invalid_input"; issues: ValidationIssue[] }
  | { type: "dependency_unavailable"; dependency: string }

```

Translate infrastructure/provider failures at the adapter boundary.

A caller should not need to understand a vendor SDK’s entire error model.

Preserve useful causal information for diagnostics without leaking implementation detail across the architecture.

---

---

# 16. Configuration Is an Input Boundary

Do not scatter direct environment access through the system.

Bad:

```ts
process.env.API_URL

```

throughout many modules.

Prefer:

```ts
interface AppConfig {
  apiUrl: URL
  port: number
  environment: Environment
}

```

Validate configuration once during startup.

Missing or malformed required configuration should fail loudly and early.

Pass modules only the configuration they require.

---

---

# 17. Secrets Must Stay Secret

Never commit or production-log:

- API keys;
- access tokens;
- refresh tokens;
- cookies;
- passwords;
- auth headers;
- private credentials.

Tests use fake credentials.

Live integration tests may read secrets from the approved environment but must never:

- serialize them into fixtures;
- save them to screenshots;
- write them to evidence bundles;
- include them in errors or logs.

When reviewing a diff, explicitly check for accidental secret exposure.

---

---

# 18. Logging Is an Interface

Logs exist for humans and machines trying to understand what happened.

Prefer structured logging.

Example:

```ts
logger.info("invoice processed", {
  invoiceId,
  durationMs,
  result: "paid",
})

```

Prefer useful identifiers and outcome fields over giant serialized payloads.

Avoid logging full:

- HTTP bodies;
- model prompts;
- provider responses;
- auth data;
- user-sensitive content

unless explicitly necessary, protected, and approved.

Do not debug by permanently adding excessive logging.

---

---

# 19. Use the Cheapest Test That Proves the Behavior

Default testing hierarchy:

```text
pure unit test
      ↓
module contract test
      ↓
integration test
      ↓
end-to-end test

```

Do not prove simple deterministic logic through slow E2E tests.

Do not claim a real integration works because a unit mock was green.

Choose the layer based on what must actually be proven.

---

---

# 20. Every Module Needs a Verification Story

For every meaningful module, be able to answer:

> How do we know this works?

Examples:

### Pure transformation

Deterministic input/output tests.

### Repository

Contract tests against an isolated real database.

### HTTP client

Stubbed transport tests plus live integration where meaningful.

### Queue consumer

Deterministic message handling tests plus real queue integration when required.

### UI component

Component behavior tests.

### User workflow

End-to-end verification through the actual surface.

If a module is extremely difficult to verify independently, inspect whether its responsibilities are too broad or its boundaries unclear.

---

---

# 21. Test Contracts, Not Decomposition

Prefer tests of observable behavior.

Avoid tests whose primary purpose is to assert:

- private helper calls;
- private fields;
- exact internal call ordering;
- implementation-specific decomposition.

A safe internal refactor should usually not require rewriting most tests.

Tests are part of the module contract.

---

---

# 22. Use Fakes at Genuine Effect Boundaries

Useful fakeable dependencies include:

- clock;
- randomness;
- network;
- storage;
- email;
- payments;
- external APIs;
- queues;
- filesystem.

Avoid manufacturing interfaces merely so every internal collaborator can be mocked.

Too much mocking results in tests that prove:

> The code called the mock the way the test expected.

rather than:

> The product behavior is correct.

---

---

# 23. Inject Time When Time Affects Behavior

When logic depends on time, avoid scattering:

```ts
Date.now()

```

through domain logic.

Prefer a clock seam where deterministic behavior matters:

```ts
interface Clock {
  now(): Date
}

```

This is especially useful for:

- expiration;
- retention;
- scheduling;
- retries;
- timeout policy;
- date-based state transitions.

---

---

# 24. Do Not Synchronize Tests With Arbitrary Sleeps

Avoid:

```ts
await sleep(500)

```

as a correctness mechanism.

Prefer waiting for a real observable condition:

- event emitted;
- state reached;
- request resolved;
- DOM changed;
- queue drained;
- connection established.

Always use bounded waits.

If a test needs an arbitrary sleep to avoid a race, investigate the missing synchronization or ownership boundary.

---

---

# 25. Reproduce Bugs Before Fixing Them

For meaningful bugs:

1. reproduce the failure;
2. reduce it to the smallest useful scenario;
3. capture a regression test where practical;
4. identify the root cause;
5. fix the root cause;
6. prove the regression;
7. run broader verification.

Do not patch symptoms based on a guess.

---

---

# 26. Performance Work Requires Measurement

Do not add performance complexity because something “might be slow.”

Before a performance-oriented change:

1. measure current behavior;
2. identify the actual bottleneck;
3. define the desired improvement;
4. make the smallest appropriate change;
5. measure again.

Keep durable evidence for important performance decisions.

Performance abstractions without measurements are speculation.

---

---

# 27. Infrastructure Must Earn Its Complexity

Do not casually introduce:

- caches;
- queues;
- workers;
- event buses;
- new databases;
- search engines;
- distributed locks;
- additional services;
- custom framework layers.

Before adding infrastructure, explain:

- which current problem it solves;
- evidence that the problem exists;
- why current mechanisms are inadequate;
- operational burden introduced;
- how correctness will be verified.

Future flexibility alone is usually insufficient justification.

---

---

# 28. Prefer Boring, Established Technology

Use current repository conventions and mature libraries where they meet the requirement.

A new dependency should earn its place.

Evaluate:

- maintenance;
- security;
- TypeScript support;
- ecosystem maturity;
- bundle/runtime cost;
- operational burden;
- interoperability.

Do not replace working technology solely because another tool is newer or fashionable.

---

---

# 29. UI Code Should Express Product Behavior, Not Own Everything

For React or similar UI systems, components should primarily:

```text
receive state
→ render
→ emit user intent

```

Keep domain and application logic outside large UI components where practical.

Avoid components that simultaneously own:

- API logic;
- domain rules;
- state machine logic;
- formatting;
- analytics;
- persistence;
- rendering.

Use composition.

Do not invent a private UI framework unless the repository has a demonstrated need.

---

---

# 30. Keep HTTP Boundaries Thin

Preferred HTTP flow:

```text
HTTP request
     ↓
authenticate / parse / validate
     ↓
project-owned command/query
     ↓
application/domain
     ↓
project-owned result
     ↓
map to HTTP response

```

Do not pass request/response framework objects deep into domain logic.

Route/controller layers should be understandable without knowing the full business implementation.

---

---

# 31. Persistence Is an Adapter Boundary

Keep database-specific representations close to persistence modules.

Avoid leaking:

- ORM row types;
- SQL-specific details;
- driver objects

into domain logic.

Transactions require explicit ownership.

Avoid hidden database calls triggered by arbitrary getters or model methods.

Watch for:

- N+1 behavior;
- accidental full-table reads;
- missing transaction boundaries;
- non-idempotent retries.

Schema changes require migration verification.

---

---

# 32. Public Contracts Require Compatibility Thinking

When modifying a consumed API, event schema, package interface, or persisted format:

- identify consumers;
- determine compatibility impact;
- prefer additive migration where practical;
- update runtime schemas;
- update TypeScript types;
- test transitional behavior when needed.

Do not silently break externally relied-upon contracts.

---

---

# 33. Work in Vertical, Verifiable Slices

Prefer:

```text
one useful behavior
      ↓
test
      ↓
implementation
      ↓
integration
      ↓
verification
      ↓
commit

```

over:

```text
design complete architecture
→ build many layers
→ connect everything at the end

```

Vertical slices expose architectural mistakes sooner.

Each slice should leave the repository coherent.

---

---

# 34. Refactor With Behavioral Safety

Refactoring means intentionally preserving externally observable behavior.

Before a significant refactor:

1. identify behavior that must remain stable;
2. establish tests/evidence;
3. refactor in small increments;
4. keep verification green;
5. avoid bundling unrelated features.

Prefer improving a specific module boundary over repository-wide abstraction campaigns.

---

---

# 35. Comments Explain Why

Useful comments explain:

- non-obvious invariants;
- provider quirks;
- safety constraints;
- historical reasons;
- intentionally surprising behavior.

Bad:

```ts
// Increment counter
counter++

```

Good:

```ts
// Delivery is at-least-once, so the idempotency record must
// be persisted before executing the external side effect.

```

Prefer self-explanatory code for “what.”

Use comments for “why.”

---

---

# 36. Name Things From the Domain

Prefer:

```text
InvoiceReconciliation
AccessPolicy
DocumentRevision
RetryBudget
SubscriptionRenewal

```

over:

```text
Manager
Helper
Common
Utils
Processor
ThingService

```

Generic names often reveal unclear responsibility.

A module should usually be nameable by what it owns.

---

---

# 37. File Size Is Not an Architecture Metric

Do not split files merely because they cross an arbitrary line count.

Split when responsibilities diverge.

A cohesive 300-line module can be healthier than six 50-line forwarding wrappers.

Likewise, an 80-line file with unrelated concepts may need separation.

Optimize for cohesion and locality, not file-count aesthetics.

---

---

# 38. Dependency Injection Should Stay Simple

Inject real effect boundaries where it improves:

- replacement;
- deterministic testing;
- ownership clarity.

Plain explicit construction is often enough:

```ts
const repository = new PostgresOrderRepository(db)
const gateway = new StripePaymentGateway(stripe)
const checkout = new CheckoutService(repository, gateway)

```

Do not build a dependency-injection framework unless the system genuinely requires one.

Prefer visible dependencies over global service locators.

---

---

# 39. Avoid Mutable Global State

Mutable globals obscure:

- ownership;
- lifecycle;
- tests;
- concurrency.

When a process-wide resource is necessary, give it:

- explicit initialization;
- clear owner;
- cleanup;
- test reset/isolation strategy.

Do not use singleton state as a shortcut around dependency design.

---

---

# 40. Security Is Behavior

Security should be verifiable, not aspirational.

Consider:

- authentication;
- authorization;
- validation;
- secret handling;
- injection;
- SSRF;
- XSS;
- CSRF;
- unsafe deserialization;
- dependency vulnerabilities;
- destructive operations;
- privacy/data exposure.

Security-sensitive rules belong at clear boundaries and should have tests where practical.

Never weaken a security boundary merely to simplify a test or make CI green.

---

---

# 41. Privacy and Data Minimization

If the product handles user-sensitive or business-sensitive information:

- collect only what is required;
- persist only what is required;
- avoid unnecessary raw payload logging;
- define data ownership;
- define retention where relevant;
- ensure debugging tools do not accidentally become data stores.

Prefer derived, minimal diagnostic information over copying full sensitive payloads into logs/evidence.

Treat privacy as an architectural property.

---

---

# 42. Accessibility Is Correctness

For user-facing interfaces, accessibility is not optional polish.

Use:

- semantic elements;
- keyboard-operable controls;
- visible focus states;
- accessible names;
- adequate contrast;
- platform conventions.

Critical workflows should remain usable without a mouse.

When changing UI behavior, include accessibility in verification.

---

---

# 43. Do Not Add Future Architecture Without Present Need

Avoid speculative layers such as:

- repository factories for only one repository;
- provider registries for only one provider;
- event buses for direct local calls;
- generic workflow frameworks for one workflow;
- caching before a measured bottleneck;
- abstraction layers whose only justification is “we may need this.”

Design clean seams where actual external effects exist.

Do not build hypothetical systems.

---

---

# 44. Prefer Reversible Decisions Early

When requirements are evolving:

- prefer simple implementations;
- preserve clean seams at expensive boundaries;
- avoid locking domain logic to external providers;
- avoid premature distributed architecture;
- avoid unnecessary persisted formats.

Make cheap decisions easy to change.

Spend architectural complexity where reversal would otherwise be expensive.

---

---

# 45. Know What Must Stay Local

When modifying a subsystem, identify what should remain locally understandable.

A developer working on one module should ideally not need to understand the entire system.

If a small behavioral change requires edits across many unrelated packages, investigate whether:

- responsibilities are misplaced;
- provider types leaked;
- state ownership is unclear;
- orchestration is too broad;
- a missing domain abstraction exists.

Locality of change is a signal of architectural health.

---

---

# 46. Dependency Changes Need Justification

When adding a dependency, ask:

- Can existing code solve this simply?
- Is the library mature?
- Is it maintained?
- Is the license acceptable?
- What security/runtime cost does it add?
- Is the API stable?
- Does it reduce more complexity than it introduces?

Avoid adding packages for trivial utilities.

Record significant dependency choices when the rationale will matter later.

---

---

# 47. Migrations Must Be Forward-Safe

For schema/data migrations:

- understand existing production shape;
- avoid assuming a clean database;
- make rollout ordering explicit;
- preserve backwards compatibility where staged deployment requires it;
- make destructive steps deliberate;
- verify against representative existing data.

Where possible:

```text
expand
→ migrate
→ switch
→ contract

```

rather than an atomic breaking migration.

---

---

# 48. Idempotency for Repeatable Effects

Operations that may be retried or delivered more than once should define idempotency behavior.

Especially:

- webhooks;
- queue messages;
- payment actions;
- email-triggered workflows;
- scheduled jobs;
- external callbacks.

Do not assume exactly-once delivery unless the underlying system truly guarantees it.

Test duplicate delivery when relevant.

---

---

# 49. Retry Only Known-Transient Failures

Retries are not generic error handling.

Before retrying, determine:

- whether the operation is safe to repeat;
- whether the error is likely transient;
- whether backoff is needed;
- whether retry amplification can occur;
- what the maximum retry budget is.

Do not retry validation errors, authorization failures, or deterministic bad input.

Retry policy belongs at a clear ownership boundary.

---

---

# 50. Cache Only With Explicit Semantics

If adding or changing caching, define:

- source of truth;
- key;
- TTL;
- invalidation;
- stale behavior;
- consistency expectations;
- failure fallback.

“Add a cache” is incomplete architecture.

Incorrect cached data can be worse than slow correct data.

Prefer no cache until requirements justify one.

---

---

# 51. Events Need Contracts and Ownership

When using event-driven architecture, define:

- event schema;
- producer ownership;
- consumer semantics;
- ordering expectations;
- delivery guarantees;
- idempotency;
- versioning.

Do not use an event bus merely to avoid direct dependencies inside a single process.

Events are useful when temporal decoupling is actually required.

---

---

# 52. Background Jobs Need Observable State

Long-running/background work should expose enough state to understand:

- queued;
- running;
- succeeded;
- failed;
- retried;
- cancelled.

Do not create jobs that disappear into invisible async execution.

Make operational failure diagnosable.

---

---

# 53. Feature Flags Are Temporary Architecture

If using a feature flag, define:

- what decision it gates;
- default behavior;
- ownership;
- rollout plan;
- removal condition.

Do not allow dead flags to become permanent branches.

Test both paths while both are supported.

Remove obsolete flags promptly.

---

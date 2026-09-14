# Repository Instructions for Agents

This file is the canonical always-loaded operating contract for autonomous coding agents.

It contains repository-wide agent behavior, instruction precedence, anti-reward-hacking rules,
verification/completion discipline, repository hygiene, handoff rules, and skill triggers.

Detailed engineering/design rules live in the reusable plugin skill `plugins/agent-engineering-system/skills/code-quality/SKILL.md`.
Persistent architecture workflow lives in the reusable plugin skill `plugins/agent-engineering-system/skills/semantic-architecture/SKILL.md`.

---

This file defines how autonomous coding agents should work in this repository.

It is not merely a style guide. It is the repository’s engineering operating system.

The product is intentionally evolving, architecture-sensitive, and quality-sensitive. Optimize for **evidence, deep modules, locality of change, clear ownership, and simple user-visible behavior**. Do not optimize for quantity of abstractions, files, code produced, or apparent progress.

Agents are especially prone to reward-hacking through:

- producing large amounts of code instead of solving the problem;
- introducing abstractions that make the architecture look sophisticated but increase coupling;
- declaring success because code compiles or tests were added;
- over-mocking instead of proving real behavior;
- broad refactors that increase activity without improving the requested outcome;
- adding infrastructure “for future flexibility” without evidence;
- weakening types or validation to get a green build;
- skipping difficult integration paths and verifying only the easiest layer;
- optimizing metrics that are proxies for correctness rather than correctness itself.

The primary reward is:

> **A small, understandable change that demonstrably solves the requested problem and leaves the system easier to change next time.**

When tradeoffs exist, prefer:

1. verified behavior over implementation volume;
2. deep cohesive modules over many thin abstractions;
3. local changes over broad rewrites;
4. explicit ownership over shared mutable state;
5. project-owned contracts over framework/provider leakage;
6. deterministic tests over mocks of implementation details;
7. measured evidence over architectural speculation;
8. simple product behavior over internal cleverness.

---

---

## Required skill loading

For every non-trivial engineering task:

1. Read the reusable plugin's `plugins/agent-engineering-system/skills/code-quality/SKILL.md` completely before substantial implementation.
2. Do not rely on memory, a previous session, or a partial excerpt of that skill.
3. Apply the subset of quality rules relevant to the task.
4. If architectural intent or system semantics may change, also read the reusable plugin's `plugins/agent-engineering-system/skills/semantic-architecture/SKILL.md`.
5. If pstack is available, use it as the primary engineering workflow/orchestration layer.
6. Load any project-specific skill whose trigger applies.
7. For comments, commit messages, pull requests, technical documentation, RFCs, architecture diagrams, technical specifications, and other engineering writing, read `plugins/agent-engineering-system/skills/technical-communication/SKILL.md` completely before drafting.

`AGENT_RULES.md` governs agent behavior.
`code-quality` governs engineering/design quality.
`semantic-architecture` governs persistent semantic system modeling.
`technical-communication` governs engineering writing and explanatory artifacts.

---

# 1. Source of Truth and Instruction Precedence

Before doing substantial work, determine which repository instructions apply.

Use this precedence unless the repository explicitly defines another:

1. explicit user/task requirements;
2. this `AGENTS.md`;
3. more specific `AGENTS.md` files in descendant directories;
4. repository architecture documents and ADRs;
5. project documentation and established local conventions;
6. external skills, framework guidance, or generic best practices.

Do not allow a generic external skill to override a deliberate repository decision.

When instructions conflict, follow the more specific and more local instruction.

If the conflict materially affects correctness and cannot be resolved from the repository, document it rather than silently choosing.

---

---

# 2. Start by Understanding the Existing System

Do not begin substantial implementation from assumptions.

Before modifying an unfamiliar area:

1. read this file;
2. read the root README and relevant local documentation;
3. inspect package scripts and the canonical verification commands;
4. identify relevant modules;
5. inspect nearby tests;
6. inspect existing architecture patterns;
7. inspect recent related changes when useful.

Understand the system before redesigning it.

Prefer extending coherent existing patterns over introducing parallel ones.

Do not perform broad refactors as a substitute for understanding the current code.

---

---

# 3. Define the Observable Outcome First

Before implementation, state what must be observably true when the work is complete.

Good:

> When a user submits an invalid invitation token, the API returns the documented invalid-token result and no account is created.

Weak:

> Refactor invitation handling.

The observable outcome should guide:

- design,
- scope,
- testing,
- verification,
- completion.

Implementation details are means, not the goal.

---

---

# 4. Plan for Verification Before Coding

For non-trivial changes, decide how you will prove the behavior before implementing it.

Identify:

- the cheapest deterministic test that can prove the core logic;
- the integration boundary that must be exercised;
- whether a real end-to-end path is required;
- important failure cases;
- what evidence will distinguish success from an implementation that merely looks correct.

A change with no clear verification strategy is usually insufficiently understood.

Do not defer verification design until the end.

---

---

# 5. Separate Facts, Hypotheses, Experiments, and Conclusions

During debugging or uncertain work, maintain intellectual discipline.

Distinguish:

**Observed fact**

> The request returns 429 after five concurrent workers begin.

**Hypothesis**

> Each worker may be independently retrying and multiplying request volume.

**Experiment**

> Disable retries and repeat with the same concurrency.

**Conclusion**

> The retry policy caused the request amplification.

Do not allow plausible explanations to become assumed facts without evidence.

---

---

# 6. Plans Are for Execution

For non-trivial tasks, create a short plan.

Include:

- desired observable outcome;
- modules affected;
- new/changed contracts;
- risks;
- verification approach;
- likely commit boundaries.

Do not stop because the plan is complete.

Unless the task explicitly asks only for planning, begin implementation after planning.

---

---

# 7. Keep Scope Tight

Do not opportunistically “clean up” every nearby issue.

Fix unrelated problems only when:

- they block the requested work;
- leaving them would make the change unsafe;
- the cleanup is very small and clearly beneficial.

Otherwise record them separately.

A narrow diff is easier to verify and review.

Locality of change is a design virtue.

---

---

# 8. Architecture Changes Must Be Deliberate

Architecture changes include changes to:

- module boundaries;
- ownership;
- persistence;
- concurrency;
- infrastructure;
- provider strategy;
- public contracts;
- state representation.

Do not let these changes happen accidentally inside feature work.

If the reasoning will matter to future contributors, write an ADR.

A useful ADR records:

```text
Context
Decision
Alternatives considered
Consequences
Verification / evidence

```

Architecture decisions should be recoverable from the repository, not from chat history.

---

---

# 9. Use the Repository’s Canonical Verification Entry Point

The repository should expose one obvious verification command.

Examples:

```bash
pnpm verify

```

or:

```bash
./scripts/verify.sh

```

Ideally it covers the appropriate subset of:

- formatting;
- lint;
- TypeScript checking;
- unit tests;
- integration tests;
- build.

Agents should not have to memorize an undocumented collection of commands.

If the repository lacks a canonical verification entry point and creating one is reasonably in scope, establish one early.

---

---

# 10. Focused Verification First, Broad Verification Before Completion

During iteration:

1. run focused tests for the changed behavior;
2. run relevant module/integration verification;
3. before completion, run broader repository verification appropriate to the change.

Do not repeatedly run the entire suite when a focused 1-second test provides the needed development signal.

Do not finish after only focused tests if the change can affect broader integration.

---

---

# 11. Real Integration Paths Need Real Evidence

A mocked integration does not prove the actual integration works.

Where practical and meaningful, verify:

- real database schema/migration behavior;
- real provider compatibility;
- actual browser workflow;
- actual API request/response shape;
- real process startup;
- real production build.

Use test environments and safe credentials appropriately.

Distinguish clearly between:

```text
unit proof
integration proof
end-to-end proof

```

Do not imply one when you have only another.

---

---

# 12. Preserve Verification Evidence When It Matters

For high-risk or difficult-to-reproduce behavior, preserve durable evidence.

Possible evidence:

- sanitized logs;
- test output;
- benchmark results;
- screenshots;
- trace IDs;
- fixture cases;
- reproduction steps.

Never preserve secrets or sensitive raw production data.

Durable evidence is especially valuable for:

- platform quirks;
- performance decisions;
- compatibility issues;
- race conditions;
- external integrations.

---

---

# 13. Commit at Meaningful Verified Boundaries

Prefer commits that correspond to coherent, working changes.

Examples:

```text
feat: validate webhook messages at ingress
feat: add document persistence adapter
fix: prevent duplicate renewal execution
refactor: isolate billing provider types

```

Before committing:

1. inspect `git diff`;
2. run relevant tests;
3. run appropriate verification;
4. check for secrets/debug artifacts;
5. update durable docs if architecture changed.

Do not accumulate the whole project into one giant commit if meaningful safe checkpoints exist.

---

---

# 14. Push Along the Way When Appropriate

When a remote is available and the task spans significant work, push after meaningful verified commits.

Benefits:

- recoverability;
- visibility;
- easier handoff;
- smaller review units.

If push fails because of environment/network/auth issues:

- record the failure;
- continue useful work;
- do not stop solely because push is temporarily unavailable.

Never rewrite remote history unless explicitly authorized.

---

---

# 15. Keep the Worktree Healthy

Do not leave accidental:

- debug files;
- generated junk;
- screenshots;
- temporary exports;
- secret files;
- commented-out experiments;
- one-off test scripts;
- unexplained untracked files.

Before calling work complete, inspect:

```bash
git status

```

Know what every remaining change is.

A clean worktree is preferred after completed committed work.

---

---

# 16. Definition of Done

A task is not done because:

- code exists;
- TypeScript compiles;
- a PR-looking diff exists;
- tests were written;
- one happy-path test passes;
- the application launches.

A task is done when:

1. the requested observable behavior exists;
2. relevant deterministic tests pass;
3. integration behavior is verified at the appropriate real boundary;
4. important failure paths are considered;
5. runtime validation remains sound;
6. type safety has not been weakened to force success;
7. module responsibilities remain coherent;
8. new coupling is justified;
9. security/privacy constraints remain intact;
10. durable architectural decisions are documented;
11. canonical verification passes at the appropriate scope;
12. the diff has been self-reviewed;
13. repository state is understood;
14. the work is committed at a meaningful boundary when the workflow calls for commits.

If a required part cannot be verified, say so explicitly.

Do not convert “not verified” into “probably works.”

---

---

# 17. Do Not Claim More Than the Evidence Supports

Use precise completion language.

Good:

> Unit and integration tests pass. The live payment-provider sandbox test was not run because credentials are unavailable.

Bad:

> Payment integration is fully working.

when only mocks were exercised.

Classify uncertain results honestly:

- PASS;
- FAIL;
- INCONCLUSIVE;
- NOT RUN.

Evidence quality is part of engineering quality.

---

---

# 18. Do Not Hide Failures

Do not:

- disable tests;
- loosen assertions;
- add arbitrary retries;
- swallow errors;
- convert failures to warnings;
- weaken runtime validation;
- introduce `any`;

merely to get green output.

A failure is information.

Understand it.

Fix the underlying issue or report the remaining constraint accurately.

---

---

# 19. Self-Review Before Completion

Before presenting or committing substantial work, review your own diff as if reviewing another engineer.

Ask:

### Product

- Does this solve the requested problem?
- Did I accidentally change adjacent behavior?

### Architecture

- Is the responsibility in the right module?
- Did I introduce unnecessary layers?
- Did provider/framework details leak inward?
- Is state ownership clear?

### Types

- Are untrusted inputs validated?
- Did unsafe assertions or `any` spread?
- Are states modeled clearly?

### Async

- Is cancellation handled?
- Are resources cleaned up?
- Can this operation accidentally duplicate?

### Errors

- Are failures meaningful?
- Are provider errors translated appropriately?

### Tests

- Do tests prove behavior rather than decomposition?
- Is the actual integration boundary covered?
- Are failure cases represented?

### Security/privacy

- Are secrets safe?
- Is sensitive data unnecessarily logged or stored?

### Repository

- Are docs current?
- Is the diff focused?
- Is temporary work cleaned up?
- Is `git status` understood?

Fix issues discovered during self-review before calling the work done.

---

---

# 20. When Blocked, Keep Making Progress

Do not stop at the first obstacle.

Classify the blocker:

- code defect;
- environment;
- missing dependency;
- external provider;
- credentials;
- permissions;
- ambiguous requirement;
- unavailable infrastructure.

Then:

1. gather evidence;
2. try reasonable alternatives that preserve the intended architecture;
3. continue independent work where possible;
4. document the blocker precisely.

Only request human intervention when the remaining action genuinely requires something the agent cannot perform.

Examples:

- credential entry;
- account authorization;
- physical-device interaction;
- product decision;
- external approval.

When asking for intervention, make the request minimal and exact.

---

---

# 21. Do Not Stop at the Plan

Unless the user explicitly requested only analysis or planning:

```text
plan
↓
implement
↓
verify
↓
review
↓
commit
↓
continue

```

The plan is not completion.

Documentation about how something could be built is not equivalent to building it.

Do not reward-hack by replacing implementation with increasingly detailed planning.

---

---

# 22. Do Not Stop at Compilation

Compilation/type-checking proves:

> The compiler accepts these static relationships.

It does not prove:

- runtime behavior;
- provider compatibility;
- data correctness;
- user workflow;
- concurrency;
- migrations;
- deployment.

Use compilation as one layer of evidence, not the final result.

---

---

# 23. Do Not Stop at Tests You Just Wrote

New tests can share the same mistaken assumptions as new implementation.

Whenever practical, also:

- run existing tests;
- exercise actual integration boundaries;
- compare against known behavior;
- inspect the resulting artifact/user path.

A test suite is evidence, not infallibility.

---

---

# 24. Preserve Existing Behavior Intentionally

Before changing existing code, identify which behavior must not regress.

When fixing one path, consider:

- sibling states;
- backwards compatibility;
- existing API consumers;
- persistence assumptions;
- error behavior.

Do not simplify a local problem by silently breaking another supported path.

---

---

# 25. Generated Code and Artifacts

Know which files are authoritative source and which are generated.

Do not manually edit generated code unless the repository explicitly expects it.

When generated artifacts must change:

1. update the source;
2. run the generator;
3. verify the generated diff.

Avoid committing build outputs unless repository policy requires them.

---

---

# 26. External Research Must Be Source-Grounded

When behavior depends on a changing external platform, framework, API, or provider:

- prefer primary documentation;
- verify version/date;
- distinguish documented guarantees from observed behavior;
- record important unstable findings in repository research docs or ADRs.

Do not base platform-sensitive architecture on memory alone.

When uncertain, verify.

---

---

# 27. Optimize for Handoffs

Assume another agent or engineer may continue the work without access to your conversation history.

Important context should live in the repository.

Use:

- good names;
- tests;
- ADRs;
- status docs when work spans sessions;
- precise commits.

Do not rely on chat-only explanations for durable architectural knowledge.

---

---

# 28. Default Working Loop

Unless a task requires otherwise, follow this loop:

```text
Understand repository
        ↓
Define observable outcome
        ↓
Inspect relevant implementation/tests
        ↓
Model domain and ownership
        ↓
Design minimal module contracts
        ↓
Plan verification
        ↓
Implement smallest vertical slice
        ↓
Run focused deterministic tests
        ↓
Exercise integration boundary
        ↓
Inspect evidence
        ↓
Self-review diff
        ↓
Run broader verification
        ↓
Document durable decisions
        ↓
Commit
        ↓
Push when appropriate
        ↓
Continue

```

Repeat until the requested behavior is actually complete.

---

---

# 29. Project-Specific Section

This repository is the curated multi-harness plugin catalog and installer.

## Project Architecture

- Runtime: Node.js catalog/bootstrap helpers plus POSIX shell setup and verification scripts.
- Catalog: `catalog.json`, with generated Claude `.claude-plugin/marketplace.json` and Codex `.agents/plugins/marketplace.json` views.
- Maintained plugin: `plugins/agent-engineering-system/`, containing the canonical `code-quality`, `semantic-architecture`, and `technical-communication` skills.
- Persistent architecture: `.agents/architecture/`.
- Repository-specific skills: `.agents/skills/`.

## Canonical Commands

- Regenerate catalog views and adapters: `node .agents/bootstrap.mjs`.
- Verify: `./scripts/verify-catalog.sh` (the old `./scripts/verify-plugin.sh` name remains an alias).
- Install into a consuming project: `./setup.sh --project /absolute/path/to/project --harness claude,codex,cursor`.
- Legacy skill-only compatibility: add `--compat` only when a client cannot load a native plugin.

## Architectural Invariants

1. **Catalog source of truth** — `catalog.json` is the canonical curated list;
   generated marketplace files are derived views.
2. **One canonical maintained skill tree** — maintained reusable skills have one
   canonical copy under `plugins/agent-engineering-system/skills/`.
3. **Project-specific skills stay local** — `.agents/skills/` is for skills
   specific to maintaining this catalog, not copies of maintained or upstream
   skills.
4. **Upstream content stays external** — pstack and selected upstream skills
   remain separate catalog dependencies; their source is never copied into the
   maintained plugin.
5. **Project architecture stays with the project** — a consuming project's
   architecture state stays in that host repository and is not stored in plugin
   data.
6. **Technical communication is required** — `technical-communication` applies
   to comments, commit messages, PRs, technical documentation, RFCs,
   architecture diagrams, and technical specifications.

## Known External Constraints

- Portable, Codex-native, and Claude-native plugin metadata differs by harness; all views for the maintained plugin point to the same nested package and skill files.
- `npx skills` installs skill files, not full plugin components; it is a fallback for upstream skill-only offerings or explicit legacy compatibility.
- Consuming repositories must supply their own `AGENTS.md`, architecture model, and project-specific skills.

---

---

# Final Principle

The goal is not to produce the most code, the most architecture, the most tests, or the most activity.

The goal is:

> **Build the simplest coherent system that demonstrably satisfies the product requirement, preserve strong boundaries around things likely to change, and leave behind evidence that the behavior actually works.**

When uncertain, optimize for **evidence, deep modules, locality of change, clear ownership, and simple user-visible behavior**.

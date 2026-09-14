---
name: technical-communication
description: Write clear, concrete engineering communication for comments, commits, pull requests, documentation, RFCs, diagrams, and specifications.
---

# Technical communication

Use this skill whenever you write or review engineering communication, including:

- code comments and docstrings;
- commit messages and pull requests;
- technical documentation and runbooks;
- RFCs, architecture decision records, and technical specifications;
- architecture diagrams and explanatory examples;
- agent instructions and handoff notes.

Optimize writing for **understanding, not for sounding technical**.

## What we reward

We reward writing that is:

- clear and direct;
- concrete about what the code actually does;
- understandable to a capable engineer who does not already have the author's context;
- as simple as the subject allows.

We do not reward technical-sounding language, unnecessary jargon, or writing that makes a simple idea sound more sophisticated than it is.

Do not optimize for the appearance of rigor. Optimize for understanding.

## Prefer plain language over opaque jargon

Avoid specialized shorthand when its meaning is not clear from the words themselves.

Examples include:

- `fail open` / `fail closed`;
- `split brain`;
- `tombstone`;
- `sidecar`;
- `strangler pattern`.

These terms are not banned. Use them when the concept itself matters, when the terminology is already established in the surrounding system, or when the term is clearer than a longer explanation.

Do not introduce them merely because they sound concise or technical.

When describing a specific behavior, prefer saying what actually happens.

Prefer:

> If the permission check cannot run, reject the request.

over:

> Fail closed if the permission check is unavailable.

Prefer:

> If the permission check cannot run, allow the request to continue.

over:

> Fail open if the permission check is unavailable.

The goal is not to eliminate technical vocabulary. Established terms such as `retry`, `fallback`, `race condition`, `idempotent`, and `at-least-once delivery` are often the clearest and most precise way to communicate an idea.

Use this test:

> Would a capable engineer who has not learned this specific term understand the behavior from the words alone?

If not, and a direct description is just as practical, use the direct description.

**Do not make the reader learn or translate terminology when you can simply state what the system does.**

## Apply the same standard to common artifacts

- Comments explain why a non-obvious decision or constraint exists. Do not restate code that is already clear.
- Commit messages name the user-visible or engineering outcome and the relevant scope.
- Pull requests lead with the problem and result, then explain the design, evidence, risks, and follow-up work.
- Documentation, RFCs, and specifications define terms on first use, explain motivation before mechanism, and cover normal behavior, failure behavior, and important tradeoffs.
- Architecture diagrams show real components, ownership, boundaries, and data or control flow. Label arrows with what moves or happens; do not use boxes and arrows as decoration.

## Final review

Before publishing, check:

1. Can a capable engineer understand the behavior without translating jargon?
2. Does the text distinguish observed behavior, intended behavior, and proposed behavior?
3. Are important conditions, failure modes, and ownership boundaries explicit?
4. Does the artifact contain the evidence a reader needs to evaluate the claim?
5. Can any sentence be made shorter without losing precision?

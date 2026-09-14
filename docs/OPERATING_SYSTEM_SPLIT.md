# Operating System Split

This file records where every section of the original generalized `AGENTS.md`
now lives.

The public documents use their own local numbering:

- `.agents/core/AGENT_RULES.md`: local sections 1–29
- `plugins/agent-engineering-system/skills/code-quality/SKILL.md`: local sections 1–53

The JSON map retains the original source identifiers as `source_number` and
the current document numbers as `local_number`.

Original source sections: 82

## `.agents/core/AGENT_RULES.md`

- 1. Source of Truth and Instruction Precedence
- 2. Start by Understanding the Existing System
- 3. Define the Observable Outcome First
- 4. Plan for Verification Before Coding
- 5. Separate Facts, Hypotheses, Experiments, and Conclusions
- 6. Plans Are for Execution
- 7. Keep Scope Tight
- 8. Architecture Changes Must Be Deliberate
- 9. Use the Repository’s Canonical Verification Entry Point
- 10. Focused Verification First, Broad Verification Before Completion
- 11. Real Integration Paths Need Real Evidence
- 12. Preserve Verification Evidence When It Matters
- 13. Commit at Meaningful Verified Boundaries
- 14. Push Along the Way When Appropriate
- 15. Keep the Worktree Healthy
- 16. Definition of Done
- 17. Do Not Claim More Than the Evidence Supports
- 18. Do Not Hide Failures
- 19. Self-Review Before Completion
- 20. When Blocked, Keep Making Progress
- 21. Do Not Stop at the Plan
- 22. Do Not Stop at Compilation
- 23. Do Not Stop at Tests You Just Wrote
- 24. Preserve Existing Behavior Intentionally
- 25. Generated Code and Artifacts
- 26. External Research Must Be Source-Grounded
- 27. Optimize for Handoffs
- 28. Default Working Loop
- 29. Project-Specific Section

## `plugins/agent-engineering-system/skills/code-quality/SKILL.md`

- 1. Model the Domain Before the Framework
- 2. Build Deep Modules
- 3. Use Interfaces at Real Seams
- 4. Keep Dependency Direction Clear
- 5. Provider Types Stop at Adapters
- 6. TypeScript Is Not Runtime Validation
- 7. Avoid `any`
- 8. Make Invalid States Hard to Represent
- 9. Mutable State Must Have an Owner
- 10. Async Work Must Have a Lifetime
- 11. Concurrency Must Be Intentional
- 12. Side Effects Belong at Clear Edges
- 13. Keep Orchestration Thin
- 14. Validate at Boundaries and Trust Internally
- 15. Treat Errors as Part of the Contract
- 16. Configuration Is an Input Boundary
- 17. Secrets Must Stay Secret
- 18. Logging Is an Interface
- 19. Use the Cheapest Test That Proves the Behavior
- 20. Every Module Needs a Verification Story
- 21. Test Contracts, Not Decomposition
- 22. Use Fakes at Genuine Effect Boundaries
- 23. Inject Time When Time Affects Behavior
- 24. Do Not Synchronize Tests With Arbitrary Sleeps
- 25. Reproduce Bugs Before Fixing Them
- 26. Performance Work Requires Measurement
- 27. Infrastructure Must Earn Its Complexity
- 28. Prefer Boring, Established Technology
- 29. UI Code Should Express Product Behavior, Not Own Everything
- 30. Keep HTTP Boundaries Thin
- 31. Persistence Is an Adapter Boundary
- 32. Public Contracts Require Compatibility Thinking
- 33. Work in Vertical, Verifiable Slices
- 34. Refactor With Behavioral Safety
- 35. Comments Explain Why
- 36. Name Things From the Domain
- 37. File Size Is Not an Architecture Metric
- 38. Dependency Injection Should Stay Simple
- 39. Avoid Mutable Global State
- 40. Security Is Behavior
- 41. Privacy and Data Minimization
- 42. Accessibility Is Correctness
- 43. Do Not Add Future Architecture Without Present Need
- 44. Prefer Reversible Decisions Early
- 45. Know What Must Stay Local
- 46. Dependency Changes Need Justification
- 47. Migrations Must Be Forward-Safe
- 48. Idempotency for Repeatable Effects
- 49. Retry Only Known-Transient Failures
- 50. Cache Only With Explicit Semantics
- 51. Events Need Contracts and Ownership
- 52. Background Jobs Need Observable State
- 53. Feature Flags Are Temporary Architecture

The original preamble/reward model and final principle live in `.agents/core/AGENT_RULES.md`.

The rule prose remains unchanged. The public headings are locally numbered so
each document reads as a complete, contiguous document. The original source
identifiers remain in `docs/OPERATING_SYSTEM_SPLIT.json` so the split can still
be audited.

`plugins/agent-engineering-system/skills/technical-communication/SKILL.md` is
new additive guidance for engineering writing. It is not a relocation of one
of the 82 original source sections and therefore is intentionally absent
from this lossless split.

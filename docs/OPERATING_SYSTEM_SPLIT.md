# Operating System Split

This file records where every numbered section of the original generalized `AGENTS.md` now lives.

Original numbered sections: 82

## `.agents/core/AGENT_RULES.md`

- 1. Source of Truth and Instruction Precedence
- 2. Start by Understanding the Existing System
- 3. Define the Observable Outcome First
- 4. Plan for Verification Before Coding
- 30. Separate Facts, Hypotheses, Experiments, and Conclusions
- 39. Plans Are for Execution
- 40. Keep Scope Tight
- 42. Architecture Changes Must Be Deliberate
- 51. Use the Repository’s Canonical Verification Entry Point
- 52. Focused Verification First, Broad Verification Before Completion
- 53. Real Integration Paths Need Real Evidence
- 54. Preserve Verification Evidence When It Matters
- 55. Commit at Meaningful Verified Boundaries
- 56. Push Along the Way When Appropriate
- 57. Keep the Worktree Healthy
- 58. Definition of Done
- 59. Do Not Claim More Than the Evidence Supports
- 60. Do Not Hide Failures
- 64. Self-Review Before Completion
- 65. When Blocked, Keep Making Progress
- 66. Do Not Stop at the Plan
- 67. Do Not Stop at Compilation
- 68. Do Not Stop at Tests You Just Wrote
- 69. Preserve Existing Behavior Intentionally
- 70. Generated Code and Artifacts
- 79. External Research Must Be Source-Grounded
- 80. Optimize for Handoffs
- 81. Default Working Loop
- 82. Project-Specific Section

## `plugins/agent-engineering-system/skills/code-quality/SKILL.md`

- 5. Model the Domain Before the Framework
- 6. Build Deep Modules
- 7. Use Interfaces at Real Seams
- 8. Keep Dependency Direction Clear
- 9. Provider Types Stop at Adapters
- 10. TypeScript Is Not Runtime Validation
- 11. Avoid `any`
- 12. Make Invalid States Hard to Represent
- 13. Mutable State Must Have an Owner
- 14. Async Work Must Have a Lifetime
- 15. Concurrency Must Be Intentional
- 16. Side Effects Belong at Clear Edges
- 17. Keep Orchestration Thin
- 18. Validate at Boundaries and Trust Internally
- 19. Treat Errors as Part of the Contract
- 20. Configuration Is an Input Boundary
- 21. Secrets Must Stay Secret
- 22. Logging Is an Interface
- 23. Use the Cheapest Test That Proves the Behavior
- 24. Every Module Needs a Verification Story
- 25. Test Contracts, Not Decomposition
- 26. Use Fakes at Genuine Effect Boundaries
- 27. Inject Time When Time Affects Behavior
- 28. Do Not Synchronize Tests With Arbitrary Sleeps
- 29. Reproduce Bugs Before Fixing Them
- 31. Performance Work Requires Measurement
- 32. Infrastructure Must Earn Its Complexity
- 33. Prefer Boring, Established Technology
- 34. UI Code Should Express Product Behavior, Not Own Everything
- 35. Keep HTTP Boundaries Thin
- 36. Persistence Is an Adapter Boundary
- 37. Public Contracts Require Compatibility Thinking
- 38. Work in Vertical, Verifiable Slices
- 41. Refactor With Behavioral Safety
- 43. Comments Explain Why
- 44. Name Things From the Domain
- 45. File Size Is Not an Architecture Metric
- 46. Dependency Injection Should Stay Simple
- 47. Avoid Mutable Global State
- 48. Security Is Behavior
- 49. Privacy and Data Minimization
- 50. Accessibility Is Correctness
- 61. Do Not Add Future Architecture Without Present Need
- 62. Prefer Reversible Decisions Early
- 63. Know What Must Stay Local
- 71. Dependency Changes Need Justification
- 72. Migrations Must Be Forward-Safe
- 73. Idempotency for Repeatable Effects
- 74. Retry Only Known-Transient Failures
- 75. Cache Only With Explicit Semantics
- 76. Events Need Contracts and Ownership
- 77. Background Jobs Need Observable State
- 78. Feature Flags Are Temporary Architecture

The original preamble/reward model and final principle live in `.agents/core/AGENT_RULES.md`.

The original numbering is preserved inside the moved section text so the split can be audited.

`plugins/agent-engineering-system/skills/technical-communication/SKILL.md` is
new additive guidance for engineering writing. It is not a relocation of one
of the 82 original numbered sections and therefore is intentionally absent
from this lossless split.

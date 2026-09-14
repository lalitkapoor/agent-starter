# Changelog

All notable changes to the curated catalog, installer, and maintained
engineering plugin are recorded here.

## [Unreleased]

- Make the repository root a curated catalog and installer with `catalog.json`.
- Move the maintained plugin and its canonical skill tree under `plugins/agent-engineering-system/`.
- Add the `technical-communication` skill for comments, commits, pull requests, documentation, RFCs, diagrams, and specifications.
- Generate Claude and Codex marketplace views from the catalog.
- Install pstack and selected Matt Pocock skills as separate upstream offerings.
- Follow declared upstream refs without commit-pinning pstack or Matt Pocock content.
- Renumber core policy and code-quality headings locally so each document reads coherently.
- Make skill-only compatibility an explicit fallback rather than the normal installation path.

## [0.1.0] - 2026-09-12

- Introduce the Agent Plugins 1.0 package layout.
- Publish `code-quality` and `semantic-architecture` as portable skills.
- Keep repository policy, project architecture, and project-specific skills outside the plugin component directories.
- Make client compatibility materialization explicit.

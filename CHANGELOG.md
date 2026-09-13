# Changelog

All notable changes to the reusable engineering plugin are recorded here.

## [Unreleased]

- Add Codex and Claude Code native manifest overlays around the canonical root `skills/` tree.
- Make `.claude/skills/` generation explicitly legacy-only and stop copying the native Claude pstack dependency there.
- Document native multi-harness installation and keep Codex marketplace metadata as a separate concern.

## [0.1.0] - 2026-09-12

- Introduce the Agent Plugins 1.0 package layout.
- Publish `code-quality` and `semantic-architecture` as portable skills.
- Keep repository policy, project architecture, and project-specific skills outside the plugin component directories.
- Make client compatibility materialization explicit.

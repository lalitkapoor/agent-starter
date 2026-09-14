# Legacy compatibility adapters

The plugin root is the canonical source for reusable skills. Native Codex,
Claude Code, and Cursor plugin loading should use the repository's native
manifest and root `skills/` directory directly.

For older or non-plugin clients, `setup.sh --compat` can still materialize
generated copies under `.cursor/skills/` and `.claude/skills/`. This is an
explicit legacy fallback, not the normal installation path.

These directories are ignored runtime outputs. Do not edit or commit them;
rerun the legacy compatibility setup after changing a canonical plugin skill
or a repository-local skill under `.agents/skills/`.

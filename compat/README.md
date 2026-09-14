# Legacy compatibility adapters

The maintained plugin root is
`plugins/agent-engineering-system/`. Native Codex, Claude Code, and Cursor
plugin loading should use the catalog and native plugin/marketplace routes
directly.

For older or non-plugin clients, `setup.sh --compat` can still materialize
generated copies under a consuming project's skill directories. This is an
explicit legacy fallback, not the normal installation path.

These directories are ignored runtime outputs. Do not edit or commit them;
rerun the compatibility setup after changing a canonical plugin skill. Do not
use them as another maintained source.

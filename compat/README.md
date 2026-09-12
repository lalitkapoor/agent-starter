# Compatibility adapters

The plugin root is the canonical source for portable skills. Some clients do
not yet load Agent Plugins 1.0 packages directly, so `setup.sh --compat` can
materialize generated skill copies under `.cursor/skills/` and `.claude/skills/`.

These directories are runtime outputs. Do not edit or commit them; rerun the
compatibility setup after changing a canonical plugin skill or a repository-local
skill under `.agents/skills/`.

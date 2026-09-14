#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const catalog = JSON.parse(fs.readFileSync(path.join(root, "catalog.json"), "utf8"));
const args = process.argv.slice(2);

function option(name, fallback = null) {
  const index = args.indexOf(name);
  return index === -1 ? fallback : args[index + 1];
}

const projectArgument = option("--project");
if (!projectArgument) {
  console.error("setup-project.mjs requires --project PATH");
  process.exit(2);
}

const project = path.resolve(projectArgument);
const harnesses = (option("--harness", "claude,codex,cursor"))
  .split(",")
  .map((value) => value.trim().toLowerCase())
  .filter(Boolean);
const marketplaceSource = option("--marketplace", "lalitkapoor/agent-starter");
const dryRun = args.includes("--dry-run");
const localOnly = args.includes("--local-only");
const compat = args.includes("--compat");
const legacyOnly = args.includes("--legacy-only");
const skipPstack = localOnly || args.includes("--skip-pstack");
const skipMatt = localOnly || args.includes("--skip-matt");
const skipInstructions = args.includes("--skip-instructions");

const supportedHarnesses = new Set(["claude", "codex", "cursor"]);
for (const harness of harnesses) {
  if (!supportedHarnesses.has(harness)) {
    console.error(`Unsupported harness: ${harness}. Choose claude, codex, or cursor.`);
    process.exit(2);
  }
}

if (!fs.existsSync(project) || !fs.statSync(project).isDirectory()) {
  console.error(`Project directory does not exist: ${project}`);
  process.exit(1);
}

const entries = new Map(catalog.plugins.map((entry) => [entry.name, entry]));
if (!entries.has("agent-engineering-system")) throw new Error("catalog.json is missing agent-engineering-system");

function shouldInstall(entry) {
  if (localOnly && entry.ownership === "upstream") return false;
  if (entry.name === "pstack" && skipPstack) return false;
  if (entry.name === "mattpocock-skills" && skipMatt) return false;
  return true;
}

function displayCommand(command, commandArgs) {
  return [command, ...commandArgs]
    .map((part) => (/^[a-zA-Z0-9_./:@%+,=-]+$/.test(part) ? part : JSON.stringify(part)))
    .join(" ");
}

function run(command, commandArgs, cwd = project) {
  const rendered = displayCommand(command, commandArgs);
  if (dryRun) {
    console.log(`DRY RUN: ${rendered}`);
    return;
  }

  const result = spawnSync(command, commandArgs, {
    cwd,
    stdio: "inherit",
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`${rendered} exited with status ${result.status}`);
  }
}

function copyDirectory(source, destination) {
  if (dryRun) {
    console.log(`DRY RUN: copy ${source} -> ${destination}`);
    return;
  }
  fs.rmSync(destination, { recursive: true, force: true });
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  fs.cpSync(source, destination, { recursive: true });
}

function copyLegacySkill(source, destination) {
  if (fs.existsSync(destination)) {
    const sourceSkill = path.join(source, "SKILL.md");
    const destinationSkill = path.join(destination, "SKILL.md");
    if (fs.existsSync(destinationSkill) && fs.readFileSync(sourceSkill, "utf8") === fs.readFileSync(destinationSkill, "utf8")) {
      return;
    }
    throw new Error(`legacy compatibility destination already exists: ${destination}`);
  }
  copyDirectory(source, destination);
}

function ensureProjectState() {
  const directory = path.join(project, ".agents", "skills");
  if (dryRun) {
    console.log(`DRY RUN: mkdir -p ${directory}`);
  } else {
    fs.mkdirSync(directory, { recursive: true });
  }
}

function replaceManagedBlock(filePath, block, initialContent) {
  const start = "<!-- BEGIN AGENT-STARTER -->";
  const end = "<!-- END AGENT-STARTER -->";
  const managed = `${start}\n${block}\n${end}`;
  const exists = fs.existsSync(filePath);
  const current = exists ? fs.readFileSync(filePath, "utf8") : initialContent;
  const escapeRegExp = (value) => value.replace(/[.*+?^${}()|[\\]\\]/g, "\\$&");
  const pattern = new RegExp(`${escapeRegExp(start)}[\\s\\S]*?${escapeRegExp(end)}`, "m");
  const next = pattern.test(current)
    ? current.replace(pattern, managed)
    : `${current.trimEnd()}\n\n${managed}\n`;

  if (dryRun) {
    console.log(`DRY RUN: update ${filePath}`);
    return;
  }
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, next);
}

function configureInstructions() {
  if (skipInstructions) return;
  const block = [
    "## Agent Starter",
    "",
    "- Use the `agent-engineering-system` plugin supplied by the `agent-starter` catalog for `code-quality`, `semantic-architecture`, and `technical-communication`; enable it in the runtime when it is only registered.",
    "- For comments, commit messages, pull requests, technical documentation, RFCs, architecture diagrams, technical specifications, and other engineering writing, read the complete `technical-communication` skill before drafting.",
    "- Use pstack as the primary workflow for non-trivial engineering work when it is installed.",
    "- For architecture-sensitive work, read the nearest `ARCHITECTURE.md` for each affected subsystem; create or update one beside the subsystem only when it has meaningful independent semantics.",
    "- Keep architecture documents beside the subsystem code they describe and project-specific skills under `.agents/skills/`.",
  ].join("\n");

  replaceManagedBlock(
    path.join(project, "AGENTS.md"),
    block,
    "# Project Agent Instructions\n\nAdd project-specific instructions outside the managed Agent Starter section.",
  );

  if (harnesses.includes("claude")) {
    replaceManagedBlock(
      path.join(project, "CLAUDE.md"),
      "Read and follow `AGENTS.md`.",
      "# Claude Code Instructions",
    );
  }

  if (harnesses.includes("cursor")) {
    replaceManagedBlock(
      path.join(project, ".cursor", "rules", "00-agent-starter.mdc"),
      "Read and follow `AGENTS.md`.",
      "---\ndescription: Agent Starter repository contract\nalwaysApply: true\n---",
    );
  }
}

function installClaude() {
  run("claude", ["plugin", "marketplace", "add", marketplaceSource, "--scope", "project"]);
  const names = catalog.plugins
    .filter((entry) => shouldInstall(entry) && entry.runtimes.claude.kind === "plugin")
    .map((entry) => entry.name);
  for (const name of names) {
    run("claude", ["plugin", "install", `${name}@${catalog.name}`, "--scope", "project"]);
  }
}

function installCodex() {
  run("codex", ["plugin", "marketplace", "add", marketplaceSource]);
  if (!dryRun) {
    console.log("Codex marketplace registered. Enable the desired catalog entries in Codex's plugin directory.");
  }
}

function installGitSubdir(source, destination) {
  if (!source.ref) throw new Error(`git-subdir source for ${destination} must declare a ref`);

  if (dryRun) {
    console.log(`DRY RUN: clone ${source.url} at ${source.ref} and copy ${source.path} -> ${destination}`);
    return;
  }

  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "agent-starter-plugin-"));
  try {
    run("git", ["clone", "--quiet", source.url, temporary], root);
    run("git", ["-C", temporary, "checkout", "--quiet", source.ref], root);
    copyDirectory(path.join(temporary, source.path), destination);
  } finally {
    fs.rmSync(temporary, { recursive: true, force: true });
  }
}

function installCursor() {
  for (const entry of catalog.plugins) {
    if (!shouldInstall(entry)) continue;
    const definition = entry.runtimes.cursor;
    if (definition.kind !== "plugin") continue;
    const destination = path.join(os.homedir(), ".cursor", "plugins", "local", entry.name);
    if (definition.source === "local") {
      copyDirectory(path.resolve(root, entry.path), destination);
    } else if (definition.source.source === "git-subdir") {
      installGitSubdir(definition.source, destination);
    } else {
      throw new Error(`Cursor route for ${entry.name} is not supported by setup.sh`);
    }
  }
}

function installSkillOnlyFallback(harness) {
  for (const entry of catalog.plugins) {
    if (!shouldInstall(entry)) continue;
    const definition = entry.runtimes[harness];
    if (!definition || definition.kind !== "skills") continue;
    for (const skill of definition.skills) {
      run("npx", [
        "--yes",
        "skills@latest",
        "add",
        definition.source,
        "--skill",
        skill,
        "--agent",
        definition.agent,
        "-y",
      ]);
    }
  }
}

function installLegacyCompatibility(harness) {
  const outputRoot = {
    claude: path.join(project, ".claude", "skills"),
    codex: path.join(project, ".agents", "skills"),
    cursor: path.join(project, ".cursor", "skills"),
  }[harness];
  for (const plugin of catalog.plugins.filter((entry) => entry.ownership === "maintained" && entry.path)) {
    const sourceRoot = path.resolve(root, plugin.path, "skills");
    for (const entry of fs.readdirSync(sourceRoot, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const source = path.join(sourceRoot, entry.name);
      const skillFile = path.join(source, "SKILL.md");
      if (fs.existsSync(skillFile)) copyLegacySkill(source, path.join(outputRoot, entry.name));
    }
  }
}

ensureProjectState();
configureInstructions();

if (legacyOnly) {
  for (const harness of harnesses) installLegacyCompatibility(harness);
  console.log(`${dryRun ? "Planned" : "Generated"} legacy skill compatibility for ${project}.`);
  process.exit(0);
}

for (const harness of harnesses) {
  if (harness === "claude") installClaude();
  if (harness === "codex") installCodex();
  if (harness === "cursor") installCursor();
  if (compat) installLegacyCompatibility(harness);
  if (harness !== "claude") installSkillOnlyFallback(harness);
}

console.log(`${dryRun ? "Planned" : "Installed"} agent-starter catalog for ${project}.`);

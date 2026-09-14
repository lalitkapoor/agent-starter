#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT=""
HARNESS="claude,codex,cursor"
MARKETPLACE="${AGENT_STARTER_MARKETPLACE:-lalitkapoor/agent-starter}"
LOCAL_ONLY=0
COMPAT=0
DRY_RUN=0
SKIP_PSTACK=0
SKIP_MATT=0

usage() {
  cat <<'EOF'
Usage:
  ./setup.sh [--project PATH] [--harness LIST] [options]

Without --project, setup regenerates and verifies this catalog only.

Options:
  --project PATH             Product repository to configure and install into.
  --harness LIST             Comma-separated: claude,codex,cursor.
  --marketplace SOURCE       Marketplace source; defaults to lalitkapoor/agent-starter.
  --local-only               Install only the maintained local plugin; skip upstream entries.
  --compat                   Also materialize maintained skills for legacy clients.
  --dry-run                  Print target-project changes and commands without applying them.
  --skip-pstack              Do not install pstack.
  --skip-matt                Do not install Matt Pocock's selected skills.
  --help                     Show this help.

Examples:
  ./setup.sh --project /path/to/my-product --harness claude,codex,cursor
  ./setup.sh --project /path/to/my-product --local-only --marketplace "$PWD"
  ./setup.sh --project /path/to/my-product --harness codex --dry-run
EOF
}

while (($#)); do
  case "$1" in
    --project)
      [[ $# -ge 2 ]] || { echo "--project requires a path" >&2; exit 2; }
      PROJECT="$2"
      shift 2
      ;;
    --harness)
      [[ $# -ge 2 ]] || { echo "--harness requires a list" >&2; exit 2; }
      HARNESS="$2"
      shift 2
      ;;
    --marketplace)
      [[ $# -ge 2 ]] || { echo "--marketplace requires a source" >&2; exit 2; }
      MARKETPLACE="$2"
      shift 2
      ;;
    --local-only)
      LOCAL_ONLY=1
      shift
      ;;
    --compat)
      COMPAT=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --skip-pstack|--skip-cross-runtime-pstack)
      SKIP_PSTACK=1
      shift
      ;;
    --skip-matt)
      SKIP_MATT=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if (( DRY_RUN )); then
  node "$ROOT/.agents/bootstrap.mjs" --check
else
  node "$ROOT/.agents/bootstrap.mjs"
fi
"$ROOT/scripts/verify-catalog.sh"

if [[ -z "$PROJECT" ]]; then
  if (( COMPAT )); then
    if (( LOCAL_ONLY )); then
      node "$ROOT/scripts/setup-project.mjs" \
        --project "$ROOT" \
        --harness claude,cursor \
        --marketplace "$ROOT" \
        --local-only \
        --compat \
        --legacy-only \
        --skip-instructions
      exit 0
    fi
    echo "--compat without --project requires --local-only; pass --project PATH for a consuming repository." >&2
    exit 2
  fi
  echo "Catalog verified. Pass --project PATH to install it into a consuming repository."
  exit 0
fi

if (( LOCAL_ONLY )); then
  MARKETPLACE="$ROOT"
fi

setup_args=(
  "$ROOT/scripts/setup-project.mjs"
  --project "$PROJECT"
  --harness "$HARNESS"
  --marketplace "$MARKETPLACE"
)
(( LOCAL_ONLY )) && setup_args+=(--local-only)
(( COMPAT )) && setup_args+=(--compat)
(( DRY_RUN )) && setup_args+=(--dry-run)
(( SKIP_PSTACK )) && setup_args+=(--skip-pstack)
(( SKIP_MATT )) && setup_args+=(--skip-matt)

node "${setup_args[@]}"

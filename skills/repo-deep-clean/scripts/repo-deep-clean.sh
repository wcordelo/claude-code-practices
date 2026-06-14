#!/usr/bin/env bash
# repo-deep-clean.sh — scan git repos, prune claude branches/worktrees, sync read-only clones.
set -euo pipefail

DRY_RUN=0
SKIP_PULL=0
SKIP_BRANCHES=0
MAX_DEPTH=4
ROOTS=()

usage() {
  cat <<'EOF'
Usage: repo-deep-clean.sh [options]

Options:
  --roots PATHS     Comma-separated directories to scan (default: ~/Documents,~/clawd,~/gbrain)
  --max-depth N     Max directory depth when discovering repos (default: 4)
  --dry-run         Print actions without executing destructive steps
  --skip-pull       Skip fetch/pull on read-only repos
  --skip-branches   Skip branch/worktree cleanup
  -h, --help        Show this help

Protected branches (never deleted): main, master, develop, dev, upstream-sync
EOF
}

log() { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --roots)
      IFS=',' read -r -a ROOTS <<< "$2"
      shift 2
      ;;
    --max-depth) MAX_DEPTH="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --skip-pull) SKIP_PULL=1; shift ;;
    --skip-branches) SKIP_BRANCHES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) warn "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ ${#ROOTS[@]} -eq 0 ]]; then
  ROOTS=("$HOME/Documents" "$HOME/clawd" "$HOME/gbrain")
fi

PROTECTED='^(main|master|develop|dev|upstream-sync)$'

is_protected() {
  [[ "$1" =~ $PROTECTED ]]
}

discover_repos() {
  local root="$1"
  [[ -d "$root" ]] || return 0
  find "$root" -maxdepth "$MAX_DEPTH" -type d -name .git 2>/dev/null \
    | sed 's|/\.git$||' \
    | sort -u
}

can_push() {
  local repo="$1" branch="$2"
  local out
  out="$(git -C "$repo" push --dry-run origin "$branch" 2>&1)" || true
  [[ "$out" != *denied* && "$out" != *403* && "$out" != *Permission* ]]
}

remove_claude_worktrees() {
  local repo="$1"
  git -C "$repo" worktree list --porcelain 2>/dev/null \
    | awk '/^worktree / {print $2}' \
    | grep -E '/\.claude/worktrees/' || true
}

delete_claude_branches() {
  local repo="$1" current="$2"
  git -C "$repo" branch --format='%(refname:short)' \
    | grep -E '^claude/' || true
}

cleanup_branches() {
  local repo="$1"
  local current wt branch

  current="$(git -C "$repo" branch --show-current 2>/dev/null || true)"
  [[ -n "$current" ]] || return 0

  # Remove claude worktrees first (blocks branch deletion)
  while IFS= read -r wt; do
    [[ -n "$wt" ]] || continue
    log "  remove worktree: $wt"
    run git -C "$repo" worktree remove --force "$wt" 2>/dev/null || run rm -rf "$wt"
  done < <(remove_claude_worktrees "$repo")

  run git -C "$repo" worktree prune 2>/dev/null || true

  # Delete claude/* branches
  while IFS= read -r branch; do
    [[ -n "$branch" ]] || continue
    [[ "$branch" == "$current" ]] && continue
    log "  delete branch: $branch"
    run git -C "$repo" branch -D "$branch"
  done < <(delete_claude_branches "$repo" "$current")

  # Delete other local branches fully merged into current (non-protected)
  while IFS= read -r branch; do
    [[ -n "$branch" ]] || continue
    [[ "$branch" == "$current" ]] && continue
    is_protected "$branch" && continue
    git -C "$repo" merge-base --is-ancestor "$branch" "$current" 2>/dev/null || continue
    log "  delete merged branch: $branch"
    run git -C "$repo" branch -d "$branch" 2>/dev/null || run git -C "$repo" branch -D "$branch"
  done < <(git -C "$repo" branch --format='%(refname:short)')
}

sync_readonly() {
  local repo="$1" branch="$2"
  local stash_name="repo-deep-clean-$(date +%Y%m%d)"
  local stashed=0

  run git -C "$repo" fetch --prune origin

  if [[ -n "$(git -C "$repo" status --porcelain 2>/dev/null)" ]]; then
    log "  stash local changes"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "[dry-run] git stash push -u -m $stash_name"
      stashed=1
    else
      git -C "$repo" stash push -u -m "$stash_name" && stashed=1 || true
    fi
  fi

  log "  pull origin/$branch"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] git pull origin $branch --no-rebase"
  elif ! git -C "$repo" pull origin "$branch" --no-rebase; then
    warn "  pull failed for $repo"
    [[ "$stashed" -eq 1 ]] && git -C "$repo" stash pop 2>/dev/null || true
    return 1
  fi

  if [[ "$stashed" -eq 1 && "$DRY_RUN" -eq 0 ]]; then
    if ! git -C "$repo" stash pop; then
      warn "  stash pop conflicted — resetting to origin/$branch (stash preserved)"
      git -C "$repo" reset --hard "origin/$branch"
    fi
  fi
}

# --- main ---

declare -a ALL_REPOS=()
for root in "${ROOTS[@]}"; do
  while IFS= read -r repo; do
    [[ -n "$repo" ]] && ALL_REPOS+=("$repo")
  done < <(discover_repos "$root")
done

# dedupe
mapfile -t REPOS < <(printf '%s\n' "${ALL_REPOS[@]}" | sort -u)

log "=== repo-deep-clean ==="
log "roots: ${ROOTS[*]}"
log "repos found: ${#REPOS[@]}"
[[ "$DRY_RUN" -eq 1 ]] && log "mode: DRY RUN"
log ""

SUMMARY_PUSH=0
SUMMARY_READONLY=0
SUMMARY_BRANCHES=0
SUMMARY_STASH=0

for repo in "${REPOS[@]}"; do
  branch="$(git -C "$repo" branch --show-current 2>/dev/null || echo "?")"
  remote="$(git -C "$repo" remote get-url origin 2>/dev/null || echo "none")"

  log "----------------------------------------"
  log "REPO: $repo"
  log "  branch: $branch | remote: $remote"

  run git -C "$repo" fetch --prune origin 2>/dev/null || true

  if [[ "$SKIP_BRANCHES" -eq 0 ]]; then
    before="$(git -C "$repo" branch | wc -l | tr -d ' ')"
    cleanup_branches "$repo"
    after="$(git -C "$repo" branch | wc -l | tr -d ' ')"
    deleted=$((before - after))
    [[ "$deleted" -gt 0 ]] && SUMMARY_BRANCHES=$((SUMMARY_BRANCHES + deleted))
    log "  branches: $before -> $after"
  fi

  [[ "$branch" == "?" ]] && continue

  behind="$(git -C "$repo" rev-list --count "HEAD..origin/$branch" 2>/dev/null || echo "?")"
  dirty="$(git -C "$repo" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  log "  behind origin/$branch: $behind | dirty files: $dirty"

  if [[ "$SKIP_PULL" -eq 1 ]]; then
    continue
  fi

  if can_push "$repo" "$branch"; then
    if [[ "$behind" =~ ^[0-9]+$ && "$behind" -gt 0 ]]; then
      log "  writable repo behind remote — pull only (no auto-push)"
      run git -C "$repo" pull origin "$branch" --no-rebase 2>/dev/null || warn "  pull failed"
      SUMMARY_PUSH=$((SUMMARY_PUSH + 1))
    fi
  else
    log "  read-only (no push access) — syncing to origin/$branch"
    sync_readonly "$repo" "$branch" && SUMMARY_READONLY=$((SUMMARY_READONLY + 1)) || true
  fi

  stash_count="$(git -C "$repo" stash list 2>/dev/null | grep -c 'repo-deep-clean-' || true)"
  SUMMARY_STASH=$((SUMMARY_STASH + stash_count))
done

log ""
log "=== summary ==="
log "repos scanned: ${#REPOS[@]}"
log "branches deleted: $SUMMARY_BRANCHES"
log "writable repos pulled: $SUMMARY_PUSH"
log "read-only repos synced: $SUMMARY_READONLY"
log ""
log "Review stashes: git stash list (look for repo-deep-clean-*)"
log "Review unpushed work on writable repos manually before pushing to main."

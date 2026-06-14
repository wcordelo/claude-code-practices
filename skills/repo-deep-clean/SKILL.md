---
name: repo-deep-clean
description: >-
  Deep cleanup across multiple git repositories: discover repos, delete stale
  claude/* branches and worktrees, remove merged local branches, and sync
  read-only clones to latest upstream. Use when the user asks for repo cleanup,
  deep clean, prune branches, sync all repos, push unpushed changes across
  projects, or clean up claude branches.
user-invocable: true
---

# Repo Deep Clean

End-to-end multi-repo git hygiene. Run this skill when the user wants a **deep cleanup** across folders/projects — not a single-repo `git push`.

## Quick start

```bash
# From this repo (after copying skills to ~/.claude/skills or ~/.cursor/skills)
SKILL_ROOT=~/.claude/skills/repo-deep-clean  # or ~/.cursor/skills/repo-deep-clean

# Preview everything first (recommended)
"$SKILL_ROOT/scripts/repo-deep-clean.sh" --dry-run

# Execute full cleanup
"$SKILL_ROOT/scripts/repo-deep-clean.sh"

# Custom scan roots
"$SKILL_ROOT/scripts/repo-deep-clean.sh" --roots "$HOME/Documents,$HOME/clawd"
```

Install: `cp -r skills/repo-deep-clean ~/.claude/skills/` (and/or `~/.cursor/skills/`).

## What this skill does

| Phase | Action |
|-------|--------|
| **Discover** | Find all `.git` repos under configured roots (default: `~/Documents`, `~/clawd`, `~/gbrain`) |
| **Branch cleanup** | Remove `.claude/worktrees/*`, delete `claude/*` branches, delete other local branches already merged into current branch |
| **Read-only sync** | Repos where `git push --dry-run` fails with permission denied → stash, pull, restore stash; reset to upstream if stash conflicts |
| **Writable sync** | Repos you can push to → pull if behind (never auto-push to `main`) |

### Protected branches (never deleted)

`main`, `master`, `develop`, `dev`, `upstream-sync`

## Agent workflow

When the user invokes this skill:

1. **Ask scope** only if unclear — default roots above are fine for most users.
2. **Run dry-run first** and show the inventory table.
3. **Confirm** if dry-run shows: stashes will be created, branches with 50+ commits deleted, or repos with large dirty diffs.
4. **Execute** the script without `--dry-run`.
5. **Report** using the template below.
6. **Do not auto-push to main** — summarize writable repos with unpushed/uncommitted work and offer to push separately.

### Optional follow-ups (separate from this skill)

- Push committed changes on writable repos → use ship/PR workflow
- Drop old stashes → `git stash list` then `git stash drop stash@{N}`
- Remove untracked junk (`implementation-notes.html`, empty `.claude/` dirs) → ask first

## Report template

```markdown
## Repo deep clean complete

### Branch cleanup
| Repo | Branches before → after | Worktrees removed |
|------|-------------------------|-------------------|

### Sync status
| Repo | Push access | Behind → current | Notes |
|------|-------------|------------------|-------|

### Stashes preserved
- `path/to/repo`: `stash@{0}` — run `git stash show -p` to inspect

### Needs manual attention
- [ ] Writable repos with uncommitted/unpushed work
- [ ] Read-only repos where stash pop conflicted (work in stash)
```

## Script flags

| Flag | Effect |
|------|--------|
| `--dry-run` | Print actions, no mutations |
| `--skip-branches` | Skip branch/worktree cleanup |
| `--skip-pull` | Skip fetch/pull |
| `--roots a,b,c` | Comma-separated scan roots |
| `--max-depth N` | Limit repo discovery depth (default 4) |

## Safety rules

- **Never** `git push --force` to `main`/`master`
- **Never** delete the currently checked-out branch
- **Never** commit `.env`, credentials, or `.claude/worktrees/` contents
- On stash pop conflict for read-only repos: **reset to `origin/<branch>`** and keep stash (script does this automatically)
- Nested repos (e.g. `monorepo/apps/openfacilitator`) are discovered independently — expected

## Trigger phrases

- "deep clean repos", "clean up all branches", "prune claude branches"
- "sync all repos", "pull everything I can't push"
- "repo hygiene", "git cleanup across projects"

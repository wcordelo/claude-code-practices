# Claude Code practices (Boris + Anthropic team)

Plan and skills based on Boris's tips and the Claude Code team's best practices.

## Contents

| Item | Purpose |
|------|--------|
| **PLAN.md** | Full plan: 10 tips + codebase discipline. Use to start complex tasks, re-plan when stuck, and run verification in plan mode. |
| **skills/** | Skills you can copy to `~/.claude/skills/` (personal, all projects) or `.claude/skills/` (per project) and commit to git. |

## Skills

| Skill | Invoke | When to use |
|-------|--------|-------------|
| **plan-mode** | `/plan-mode` or auto | Start complex tasks in plan mode; re-plan when stuck; use plan mode for verification; explore codebase for reuse. |
| **techdebt** | `/techdebt` | Find and reduce duplicated code. Run at end of session. |
| **update-claude-md** | `/update-claude-md` or auto | After a correction, update CLAUDE.md so the same mistake isn't repeated. |
| **codebase-reuse** | `/codebase-reuse` or auto | Before adding code, explore for reusable functions; in code review, check for duplication. |
| **claude-code-practices** | `/claude-code-practices` | Quick reference for all 10 Boris/team tips. |
| **repo-deep-clean** | `/repo-deep-clean` | Prune claude branches/worktrees and sync read-only git clones across projects. |

## Setup

**Use the plan**

- Start complex work with: "Enter plan mode. [task]." or open `PLAN.md` and follow section 2.
- When something goes sideways: "Switch back to plan mode and re-plan."

**Install skills (reuse across projects)**

```bash
# Personal (all projects)
mkdir -p ~/.claude/skills
cp -r claude-code-practices/skills/* ~/.claude/skills/

# Or per project (e.g. blueprint-frontend)
cp -r claude-code-practices/skills/* blueprint-frontend/.claude/skills/
```

Then commit `.claude/skills/` to the repo if you want team-wide reuse.

## References

- [Common workflows – Plan Mode & worktrees](https://code.claude.com/docs/en/common-workflows)
- [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [Terminal config](https://code.claude.com/docs/en/terminal-config)
- [Hooks – permission request](https://code.claude.com/docs/en/hooks#permissionrequest)

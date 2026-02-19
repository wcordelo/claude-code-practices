---
name: claude-code-practices
description: Boris + Claude Code team best practices. Use when the user asks "how does the team use Claude", "best practices", "Boris tips", or "Claude Code workflow".
user-invocable: true
---

# Claude Code practices (Boris + Anthropic team)

Reference for how the Claude Code team uses Claude. For the full plan, see `claude-code-practices/PLAN.md` in the repo where this skill was copied from, or the project's docs.

## 1. Parallel work
- 3–5 git worktrees, one Claude session per worktree. Biggest productivity unlock.
- `git worktree add ../project-feature-a -b feature-a` then `claude` in that dir.

## 2. Plan mode first
- Start every complex task in plan mode; pour energy into the plan so Claude can 1-shot implementation.
- When things go sideways: re-plan, don’t keep pushing.
- Use plan mode for **verification** steps too, not just the build.
- `claude --permission-mode plan` or Shift+Tab in-session.

## 3. CLAUDE.md
- After every correction: "Update your CLAUDE.md so you don't make that mistake again."
- Ruthlessly edit CLAUDE.md until mistake rate drops.

## 4. Skills
- Turn anything you do more than once a day into a skill; commit to git, reuse everywhere.
- Examples: `/techdebt` at end of session; context dump from Slack/GDrive/GitHub; dbt/code-review agents.

## 5. Bugs
- Paste Slack bug thread + "fix"; or "Go fix the failing CI tests" without micromanaging.
- Point Claude at docker logs for distributed systems.

## 6. Prompting
- Challenge: "Grill me on these changes and don't make a PR until I pass your test."
- After mediocre fix: "Knowing everything you know now, scrap this and implement the elegant solution."
- Write detailed specs before handoff.

## 7. Terminal
- Ghostty, /statusline (context + branch), named/color-coded tabs, voice dictation (fn ×2 macOS).

## 8. Subagents
- Append "use subagents" for harder problems; offload tasks to keep main context clean.
- Hooks: route permission requests to Opus 4.5 for scan + auto-approve safe ones.

## 9. Data & analytics
- Use `bq` (or any DB CLI/MCP/API) for metrics in Claude Code; BigQuery skill in codebase.

## 10. Learning
- Explanatory/Learning output style in /config; HTML slides for unfamiliar code; ASCII diagrams; spaced-repetition skill.

## Codebase discipline
- **Planning**: Explore codebase for reusable functions before proposing new code.
- **Code review**: Check for duplication; run `claude -p` in CI to report duplicated logic vs main.

---

Related skills in this set: `/plan-mode`, `/techdebt`, `/update-claude-md`, `/codebase-reuse`.

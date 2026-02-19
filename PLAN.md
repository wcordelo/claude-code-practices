# Claude Code Practices Plan (Boris + Anthropic Team)

*"There is no one right way to use Claude Code — everyone's setup is different. Experiment to see what works for you!"*

This plan distills tips from Boris (creator of Claude Code) and the Claude Code team. Use it to start complex tasks, re-plan when things go sideways, and run verification in plan mode.

---

## 1. Do more in parallel

- **Spin up 3–5 git worktrees** at once, each running its own Claude session. This is the single biggest productivity unlock.
- Prefer **worktrees** over multiple checkouts (native support in Claude Desktop).
- **Optional**: Name worktrees and use shell aliases (`za`, `zb`, `zc`) to hop between them in one keystroke.
- **Optional**: Keep a dedicated "analysis" worktree for reading logs, BigQuery, etc.

**Commands:**
```bash
git worktree add ../project-feature-a -b feature-a
cd ../project-feature-a && claude
```

Ref: [Run parallel Claude Code sessions with Git worktrees](https://code.claude.com/docs/en/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees)

---

## 2. Start every complex task in plan mode

- **Pour energy into the plan** so Claude can 1-shot the implementation.
- **Options**: Have one Claude write the plan, then a second Claude review it as a staff engineer.
- **When something goes sideways**: Switch back to plan mode and re-plan. Don’t keep pushing.
- **Verification**: Explicitly tell Claude to enter plan mode for verification steps, not just for the build.

**How:**
- In-session: **Shift+Tab** until you see `plan mode on`.
- New session: `claude --permission-mode plan`
- Headless: `claude -p "Analyze X and suggest Y" --permission-mode plan`

---

## 3. Invest in CLAUDE.md

- **After every correction**, end with: *"Update your CLAUDE.md so you don't make that mistake again."*
- Claude is very good at writing rules for itself.
- **Ruthlessly edit CLAUDE.md over time** until Claude’s mistake rate measurably drops.
- **Optional**: Have Claude maintain a notes directory per task/project, updated after every PR; point CLAUDE.md at it.

---

## 4. Create your own skills and commit them to git

- **Reuse across every project** (personal: `~/.claude/skills/`, project: `.claude/skills/`).
- If you do something **more than once a day**, turn it into a skill or command.
- **Examples from the team:**
  - `/techdebt` — run at end of every session to find and kill duplicated code.
  - Slash command that syncs 7 days of Slack, GDrive, Asana, GitHub into one context dump.
  - Analytics-engineer-style agents: write dbt models, review code, test changes in dev.

Ref: [Extend Claude with skills](https://code.claude.com/docs/en/skills#extend-claude-with-skills)

---

## 5. Let Claude fix bugs with minimal micromanagement

- **Slack MCP**: Paste a Slack bug thread and say "fix." (zero context switching.)
- **CI**: "Go fix the failing CI tests." Don’t micromanage how.
- **Distributed systems**: Point Claude at docker logs; it’s surprisingly capable.

---

## 6. Level up your prompting

- **Challenge Claude**: "Grill me on these changes and don’t make a PR until I pass your test." Or: "Prove to me this works" and have Claude diff behavior between main and your feature branch.
- **After a mediocre fix**: "Knowing everything you know now, scrap this and implement the elegant solution."
- **Handoffs**: Write detailed specs and reduce ambiguity; the more specific, the better the output.

---

## 7. Terminal & environment setup

- **Ghostty** is popular (synchronized rendering, 24-bit color, unicode).
- **Status bar**: Use `/statusline` to show context usage and current git branch.
- **Tabs**: Color-code and name terminal tabs (e.g. tmux — one tab per task/worktree).
- **Voice dictation**: Speak 3× faster; prompts get more detailed (e.g. fn ×2 on macOS).

Ref: [Terminal config](https://code.claude.com/docs/en/terminal-config)

---

## 8. Use subagents

- **Append "use subagents"** to any request where you want more compute on the problem.
- **Offload tasks** to subagents to keep the main agent’s context clean and focused.
- **Permission hook**: Route permission requests to Opus 4.5 — scan for attacks, auto-approve safe ones.

Ref: [Hooks – permission request](https://code.claude.com/docs/en/hooks#permissionrequest)

---

## 9. Use Claude for data & analytics

- Use **`bq` CLI** (or any DB CLI/MCP/API) to pull and analyze metrics on the fly.
- BigQuery skill is checked into the codebase; use it for analytics queries directly in Claude Code.
- Works for any database with a CLI, MCP, or API.

---

## 10. Learning with Claude

- **Config**: Enable "Explanatory" or "Learning" output style in `/config` for the *why* behind changes.
- **Slides**: Have Claude generate a visual HTML presentation explaining unfamiliar code.
- **Diagrams**: Ask for ASCII diagrams of new protocols and codebases.
- **Spaced repetition**: Build a skill — you explain understanding, Claude asks follow-ups, stores the result.

---

## Codebase discipline (team habit)

- **Planning**: As part of any plan, Claude must **explore the codebase for reusable functions**.
- **Code review**: Check for **duplication** in code review; do this using **`claude -p` in CI** (e.g. "look at changes vs main and report duplicated logic or patterns").

---

## Quick reference

| Goal | Action |
|------|--------|
| Parallel work | 3–5 worktrees, one Claude per worktree |
| Complex task | Start in plan mode; re-plan when stuck |
| Fewer mistakes | Update CLAUDE.md after every correction |
| Reuse & automation | Skills for daily tasks; commit to git |
| Bugs | Paste context + "fix" or "go fix failing CI" |
| Better output | Challenge Claude; ask for elegant rewrite; write detailed specs |
| Verification | Plan mode for verification steps; `claude -p` in CI for duplication |

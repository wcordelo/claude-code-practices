---
name: plan-mode
description: Start complex tasks in plan mode; re-plan when stuck; use plan mode for verification. Use when the user says "enter plan mode", "plan first", "re-plan", or when a multi-step or risky change is being discussed.
---

# Plan mode discipline (Boris + Claude Code team)

When this skill is active:

1. **Complex or multi-step work**
   - Treat the current task as plan-first: analyze the codebase with read-only operations, propose a clear plan, then implement only after the user approves (or after confirming in plan mode).
   - If the user says things have gone sideways, **switch back to plan mode** and re-plan instead of pushing more edits.

2. **Verification**
   - For verification steps (e.g. "verify this refactor", "check this is safe"), operate in a planning mindset: list what to check, which files/tests to run, and what "done" looks like before making changes.

3. **Codebase reuse**
   - As part of any plan, **explore the codebase for existing reusable functions, utilities, and patterns** before proposing new code. Prefer reusing and refactoring over duplicating.

4. **Reminders**
   - Suggest starting a session in plan mode with: `claude --permission-mode plan`
   - For headless verification (e.g. CI): `claude -p "..." --permission-mode plan`

Reference: [Common workflows – Plan Mode](https://code.claude.com/docs/en/common-workflows#use-plan-mode-for-safe-code-analysis)

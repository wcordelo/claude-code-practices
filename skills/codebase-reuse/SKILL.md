---
name: codebase-reuse
description: Before adding or changing code, explore the codebase for reusable functions, shared utilities, and existing patterns. Use when planning a feature, refactor, or when the user asks to "reuse existing code" or "check for duplication".
---

# Codebase reuse & duplication check (team habit)

When planning or implementing a feature or refactor:

1. **Before writing new code**
   - Search for existing utilities, helpers, hooks, or components that already do what you need (or most of it).
   - Use Glob, Grep, and semantic search; check `utils/`, `lib/`, `hooks/`, `components/common/`, and similar shared areas.
   - Prefer **reusing and composing** over adding new duplicate logic.

2. **In code review**
   - When reviewing changes (e.g. diff vs main), flag:
     - New code that duplicates logic that exists elsewhere.
     - Opportunities to extract shared logic instead of copying.

3. **CI / headless**
   - In CI you can run: `claude -p "Look at the changes vs main and report duplicated logic or patterns; suggest consolidation."` so every PR is checked for duplication.

4. **When this skill is active**
   - As part of any plan or implementation step, explicitly list which existing files/functions you considered and why you reused or chose not to reuse them.

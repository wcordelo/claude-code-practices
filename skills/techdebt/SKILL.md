---
name: techdebt
description: Find and reduce duplicated code and tech debt. Run at end of session or when user says /techdebt. Use when user asks to find duplication, tech debt, or "kill duplicated code".
disable-model-invocation: false
---

# Tech debt & duplication (Claude Code team habit)

When invoked (e.g. `/techdebt` or "find duplication"):

1. **Find duplicated code**
   - Search the codebase for repeated logic, copy-pasted blocks, and similar patterns (same logic in multiple files or components).
   - Prefer Grep and codebase search; consider semantic similarity, not just exact text.

2. **Report clearly**
   - For each finding: file(s), approximate line/region, and a short description of the duplication.
   - Suggest a single source of truth (e.g. shared util, hook, or component) and what could be refactored.

3. **Scope**
   - Focus on the current project or the directories the user is working in unless they ask for the whole repo.
   - If the codebase is large, prioritize areas that changed recently or that the user points to.

4. **Optional follow-up**
   - Offer to draft a refactor plan or a first patch to consolidate one of the duplications.

*Team tip: run this at the end of every session to find and kill duplicated code.*

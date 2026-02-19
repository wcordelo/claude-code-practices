---
name: update-claude-md
description: After a correction or mistake, update CLAUDE.md so the same mistake is not repeated. Use when the user says "update your CLAUDE.md", "don't make that mistake again", or after fixing a recurring error.
---

# Update CLAUDE.md after corrections (Boris + team)

When the user corrects something or you fix a mistake:

1. **Identify the rule**
   - What concrete rule or constraint would have prevented this mistake? (e.g. "Never X", "Always Y when Z", "Use A not B in this codebase.")

2. **Locate CLAUDE.md**
   - Look for `CLAUDE.md` in the current directory or project root (and parent directories). Use the one that applies to this project.

3. **Edit CLAUDE.md**
   - Add or refine a short, actionable rule. Prefer:
     - Clear "NEVER" / "ALWAYS" style where applicable.
     - One rule per mistake; avoid long paragraphs.
   - Place it in the right section (e.g. "Critical Rules", "Common Patterns", or a new "Corrections" section).

4. **Confirm**
   - Tell the user you updated CLAUDE.md and quote the new or updated rule in one line.

*"Claude is eerily good at writing rules for itself. Ruthlessly edit your CLAUDE.md over time until Claude's mistake rate measurably drops."*

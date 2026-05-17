---
name: next-hitl
argument-hint: "<issue#>"
description: Drive one iteration on the GitHub issue passed by number, by spawning an addressable teammate that stays in chat with the user through completion. Use when an issue needs human-in-the-loop sign-offs (shape decisions, commit approvals) and the user wants a single iteration on a specific issue.
---

# Next HITL

You are spawning one addressable teammate to work the GitHub issue passed by number end-to-end with the user in the loop. You do not own a loop and you do not pick the issue.

Refuse if `$ARGUMENTS` is empty or not a positive integer (issue number is required).

Spawn the teammate per `/teammate`. Pass exactly this prompt:

```
/hitl-issue $ARGUMENTS
```

The teammate runs `/hitl-issue <issue#>`, which loads the issue body + recent commits inside the teammate's own context and works the issue end-to-end with the user in chat. The teammate stays addressable through completion — the user signs off, then the teammate closes with a SendMessage summary. Surface that summary verbatim.

## Don't

- Pick the issue. The caller (or user) does. If `$ARGUMENTS` is empty, refuse.
- Pass any prompt addenda beyond `/hitl-issue $ARGUMENTS`.
- Loop. The caller (or user) decides whether to call again.

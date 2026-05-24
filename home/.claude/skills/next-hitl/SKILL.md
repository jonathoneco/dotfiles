---
name: next-hitl
argument-hint: "<issue#>"
description: Drive one iteration on the GitHub issue passed by number, by spawning an addressable teammate that stays in chat with the user through completion. Use when an issue needs human-in-the-loop sign-offs (shape decisions, commit approvals) and the user wants a single iteration on a specific issue.
---

# Next HITL

You are spawning one addressable teammate to work the GitHub issue passed by number end-to-end with the user in the loop. You do not own a loop and you do not pick the issue.

Refuse if `$ARGUMENTS` is empty or not a positive integer (issue number is required).

Spawn the teammate per `/teammate`. Pass a prompt that tells the teammate to load issue context directly:

```sh
bash ralph/next-hitl-context.sh $ARGUMENTS
```

The teammate reads that output as its issue context and works the issue with the user in chat. HITL means the user keeps the call: the teammate surfaces decisions, confirms shape calls, gets sign-offs before commits, and closes with a SendMessage summary only after the user approves the outcome. Surface that summary verbatim.

## Don't

- Pick the issue. The caller (or user) does. If `$ARGUMENTS` is empty, refuse.
- Invoke or reference the deleted duplicate HITL command.
- Loop. The caller (or user) decides whether to call again.

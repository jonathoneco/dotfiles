---
name: next-afk
argument-hint: "<issue#>"
description: Primitive-driver. Drive one iteration of work on the GitHub issue passed by number, via an addressable teammate. AFK runs auto but stays addressable so the user can chime in, pause, or unblock mid-flight. Cited by `/drive-issues` (mandatory loop subroutine, picks the issue first) and invokable directly when the user wants a single AFK iteration on a specific issue.
---

# Next AFK

You are running one iteration on the GitHub issue passed by number. Spawn a teammate per `/teammate`. You do not own the loop and you do not pick the issue.

Refuse if `$ARGUMENTS` is empty or not a positive integer (issue number is required). The caller picks; this skill couriers.

Pass `/teammate` exactly:

- **prompt** — `/afk-issue $ARGUMENTS` (the issue number passes through verbatim)
- **name** — short label, e.g. `afk`

The teammate runs `/afk-issue <issue#>`, which loads the issue body + recent commits inside the teammate's own context and works that one issue end-to-end. The teammate stays addressable so the user can chime in, pause, or unblock mid-flight.

When the teammate returns its closing summary, surface it verbatim. Whether the issue closed is observable via `gh issue view <NN> --json state` after the iteration — don't paraphrase or summarize.

## Don't

- Pick the issue. The caller does. If `$ARGUMENTS` is empty, refuse.
- Pass any prompt addenda beyond `/afk-issue $ARGUMENTS`.
- Loop. The caller decides whether to call again.

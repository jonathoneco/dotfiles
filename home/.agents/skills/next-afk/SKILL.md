---
name: next-afk
argument-hint: "<issue#>"
description: Primitive-driver. Drive one iteration of work on the GitHub issue passed by number, via a sealed sub-agent that runs to completion and returns one closing summary. Cited by `/drive-issues` (mandatory loop subroutine, picks the issue first) and invokable directly when the user wants a single AFK iteration on a specific issue.
---

# Next AFK

You are running one iteration on the GitHub issue passed by number. Spawn a **sealed sub-agent** via the `Agent` tool — it runs to completion and returns one closing message. You do not own the loop and you do not pick the issue.

Refuse if `$ARGUMENTS` is empty or not a positive integer (issue number is required). The caller picks; this skill couriers.

Spawn the Agent with:

- `subagent_type`: `general-purpose`
- `model`: `sonnet` — issue work is the volume; the caller stays on the parent model
- `description`: short label, e.g. `"AFK iteration on #<NN>"`
- `prompt`: `/afk-issue $ARGUMENTS` (the issue number passes through verbatim)

When the Agent returns, surface its closing message verbatim. Whether the issue closed on GitHub is observable via `gh issue view <NN> --json state` after the iteration — don't paraphrase or summarize.

## Don't

- Pick the issue. The caller (`/drive-issues` or the user) does. If `$ARGUMENTS` is empty, refuse.
- Use `/teammate`. NOT a teammate. No `TeamCreate`, no addressability, no `SendMessage`. AFK is sealed sub-agent only — `/next-hitl` is the teammate path.
- Pass any prompt addenda beyond `/afk-issue $ARGUMENTS`.
- Spawn on a model other than `sonnet`.
- Loop. The caller decides whether to call again.

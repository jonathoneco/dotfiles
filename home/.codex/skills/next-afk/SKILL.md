---
name: next-afk
argument-hint: "<issue#>"
description: Primitive-driver. Drive one iteration of Codex work on the GitHub issue passed by number via a sealed subagent that runs to completion and returns one closing summary. Cited by /drive-issues and invokable directly for a single AFK issue iteration.
---

# Next AFK

You are running one iteration on the GitHub issue passed by number. Spawn a sealed Codex subagent. You do not own the queue and you do not pick the issue.

Refuse if `$ARGUMENTS` is empty or not a positive integer.

Spawn one subagent with a prompt that says:

```text
Use /skill:codex-issue-worker for GitHub issue #$ARGUMENTS. Work exactly that issue to completion or to a surfaced blocker. Return one closing summary.
```

When the subagent returns, surface its closing summary verbatim. Whether the issue closed is observable via `gh issue view <NN> --json state` after the iteration; do not paraphrase or summarize.

## Don't

- Pick the issue. The caller does.
- Use Claude TeamCreate or Pi tmux flows.
- Pass prompt addenda beyond the issue-worker instruction above.
- Loop. The caller decides whether to call again.

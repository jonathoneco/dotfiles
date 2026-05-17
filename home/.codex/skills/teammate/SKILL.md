---
name: teammate
description: Spawn a single Codex subagent for one bounded work iteration. Use when a caller needs isolated context and a closing summary rather than inline execution.
---

# Teammate

You are spawning one bounded Codex subagent. This is not Claude TeamCreate and not Pi tmux. It is a sealed subagent run with a clear prompt and one closing summary.

Refuse if the caller has not supplied both a teammate prompt and a teammate name.

Spawn one subagent using the supplied prompt. Use the supplied name only as the subagent/task label. When the subagent returns, surface its closing summary verbatim.

## Don't

- Create a team.
- Spawn multiple subagents.
- Add extra work beyond the caller's prompt.
- Leave the user guessing whether the subagent finished or blocked.

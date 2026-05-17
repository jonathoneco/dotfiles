---
name: teammate
description: Spawn an addressable team-mode agent that chats with the user directly for one iteration, instead of a sealed one-shot Agent. Use when a caller (`/next-hitl`, etc.) needs an iteration that stays addressable for back-and-forth user sign-offs.
---

# Teammate

You are spawning an addressable teammate for one iteration of HITL work, surfacing its name to the user, then tearing the team down on close. You own spawn, engagement-contract surfacing, and tear-down — nothing else.

Refuse if the caller has not supplied both a teammate prompt and a teammate name.

The teammate name is what the user types to chat back. Surface it before stepping back.

## Spawn

1. Create a team if one is not already running.
2. Spawn via the `Agent` tool with the supplied `name` so the teammate is addressable.
3. Tell the user the teammate's name and that they can chat back directly.
4. Step back. The teammate runs the iteration.
5. On the teammate's closing summary, surface it verbatim and tear the team down.

## Engagement contract (caller bakes into the teammate prompt)

- Teammate output goes to the user directly.
- Teammate calls `SendMessage` to the lead ONLY for the closing summary at iteration end.
- Lead surfaces the closing summary verbatim.

The teammate does not read this skill. The caller is responsible for putting these rules into the prompt it supplies.

## Already leading team

`TeamCreate` returning `Already leading team` means the harness one-team-per-leader limit is hit. Do not retry. Pick one:

- `TeamDelete` the prior team first (loses chat-back with that team), then spawn.
- Fall back to a sealed `Agent` call (no addressability, no chat-back) and tell the caller you fell back.

## Don't

- Inline guidance into the teammate prompt beyond the caller's contract.
- Leave a team running after the closing summary.
- Spawn multiple teammates in one iteration. One teammate per iteration.
- Tear down silently if the teammate skips the closing summary — stop and surface to the user.

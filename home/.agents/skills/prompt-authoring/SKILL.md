---
name: prompt-authoring
description: Authors structured prompts for Claude Code session handoffs, subagent briefs, scoped skill invocations, issue-execution sessions, and one-shot research. Use when drafting a multi-section prompt for a fresh session, writing a subagent task brief, scaffolding a vertical-grill kickoff, asking "how should I prompt this", or reviewing whether an existing prompt is self-contained enough for a fresh reader.
---

# Prompt Authoring

## Why this matters

Claude Code prompts that a future session or subagent reads MUST be self-contained. The reading session has no transcript context — only the prompt + files it explicitly reads. A prompt that assumes "you'll figure it out" produces drift; a prompt that explicitly lays out role + state + inputs + acceptance produces continuity.

This skill teaches WHAT structure each type of prompt needs and HOW to verify it before publishing.

## The 5 prompt types

| Type | When to use | Required structure |
|---|---|---|
| **Session-handoff** | Fresh session continues paused work in same project | role + state-of-work + ordered inputs + remaining work + acceptance + discipline framing |
| **Vertical-loop kickoff** | Starting `/grill-me` scoped to one vertical/version | role + design-tree to walk + companion-menu checklist + watchdog invocation + maturation triggers + sensitive-domain considerations |
| **Issue-execution** | Build session against one `.issues/` ticket | role + read parent PRD + read vertical PRD if applicable + acceptance criteria + discipline refs (build-discipline, wiki-guardrails) |
| **Subagent brief** | Isolated task dispatched via Agent tool | scope + what's in / what's out / what another agent handles + what to report back + report length cap |
| **One-shot research** | Quick focused question to a fork or fresh agent | exact question + scope bounds + report length cap + what NOT to do |

See [EXAMPLES.md](EXAMPLES.md) for full templates per type with worked examples.

## Quick-start workflow

1. **Identify the type** — pick from the table above. Mismatched types produce mismatched scaffolds.
2. **Open EXAMPLES.md** to the matching section; copy the template.
3. **Fill the required structure** for that type. Don't skip sections to save space — sections exist because their absence produces specific failure modes.
4. **Run the self-test checklist** (below). Iterate until every box checks.
5. **Publish:**
   - Session-handoff → write to `.work/<YYYY-MM-DD>-<topic>-prompt.md` in repo (or appropriate handoff convention) so it survives chat scrollback
   - Vertical-loop kickoff → paste as session opener
   - Issue-execution → paste as session opener referencing the issue file
   - Subagent brief → pass directly in the `Agent` tool's `prompt` field
   - One-shot research → pass directly in the fork's `prompt` field

## Self-test checklist

Before publishing any prompt, verify:

- [ ] **Self-contained** — a reader with zero conversation context can execute it. Test: would a fresh Claude session understand what to do?
- [ ] **Inputs ordered** — files/docs to read are listed IN ORDER, not just enumerated. Order matters; first-read inputs frame later-read ones.
- [ ] **State explicit** — what's done vs what's remaining is separated cleanly. No "you'll figure out where we are."
- [ ] **Acceptance upfront** — what marks the work complete is stated, not implied. Reader knows when to stop.
- [ ] **Discipline framed** — what's permitted vs forbidden in this session is explicit (auto-mode? subagent dispatch? destructive ops? Notion writes?).
- [ ] **Cross-references stable** — references file paths, issue IDs, commit SHAs. NOT "earlier in the chat", "the message I sent yesterday", "you remember from last session".
- [ ] **Lived-experience corrections preserved** — anything the reader could get wrong from naive reading (synonyms, stale doc IDs, deprecated tools, sibling-repo conventions) is flagged inline.
- [ ] **Security defaults** — if any sensitive-domain rules apply, restate them (don't assume auto-loaded doctrine is in the new session's context).

## Common failure modes

See [REFERENCE.md](REFERENCE.md) for deeper guidance on:
- Why self-containment matters more than brevity
- How to choose what to include vs link
- The "trust but don't assume" principle for inputs
- Why discipline framing is non-negotiable
- Anti-patterns that look helpful but produce drift

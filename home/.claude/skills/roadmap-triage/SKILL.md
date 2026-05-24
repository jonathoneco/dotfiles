---
name: roadmap-triage
description: Fold GitHub issue updates (new opens, label transitions, closures, supersession chains) into the Wrangle operational roadmap at `docs/operations/roadmap-YYYY-MM-DD/` and mirror the same edits to the team Notion page. Use when the user says "update the roadmap", "roadmap-triage", "an update to issue NN", "new issues surfaced", "fold this into the roadmap", or after a `/triage` label flip needs to propagate to the live operational surface. Sister to the `triage` skill (matt-pocock issue-state-machine) and `wrangle-notion-capture` (canonical Notion writes).
---

# Roadmap-triage

Fold issue updates into the three-surface operational roadmap: `roadmap.md` (teammate-facing) + `jon-working-notes.md` (Jon-private) + Notion page mirror.

## When to invoke

- User mentions a specific issue change ("there's an update to #159"; "new issues surfaced"; "I just closed #X").
- After a `/triage` flip on an existing issue (e.g., #82 went `needs-triage` → `ready-for-agent`).
- A new issue was opened that belongs in someone's pile or in the stretch list.
- Periodic sync after several upstream changes the user wants reflected together.

## When NOT to invoke

- The change is purely architectural / documentation and doesn't touch any pile or stretch-list item. Edit `roadmap.md` directly without the full mirror dance.
- The change is in a closed-and-archived dir (`docs/operations/roadmap-2026-MM-DD/` where `MM-DD` is no longer the current snapshot). Roll forward to the new dated dir first.
- The user wants a fresh cluster-shape pass (a re-clustering of the whole 100+ issue queue against a new date). That's a separate session — produce a new `roadmap-YYYY-MM-DD/` directory from Phase A onward.

## Quick start

Three-phase loop per invocation:

1. **Detect the delta.** Pull what changed via `gh issue view <N>` for each named issue, `gh issue list --search "updated:>{ISO timestamp}"` for unnamed ones.
2. **Decide band + tier per issue.** See [REFERENCE.md § Band predicates](REFERENCE.md#band-predicates) and [§ Tier definitions](REFERENCE.md#tier-definitions).
3. **Apply to three surfaces in order:**
   - `roadmap.md` (Dan's pile / Jon's pile / Richard's slot / waiting-on lists / cluster index footer)
   - `jon-working-notes.md` (stretch grilling pile / snapshot counts / open user-judgment items)
   - Notion mirror (page id below) — surface proposed block edits, write on confirm
   - Commit + push with a conventional-commits message naming the issue delta

## Files to maintain

- **Operational pile surface:** `docs/operations/roadmap-YYYY-MM-DD/roadmap.md` (teammate-facing).
- **Jon-private working notes:** `docs/operations/roadmap-YYYY-MM-DD/jon-working-notes.md`.
- **Notion mirror page:** id `363884ec-3621-81e8-9487-c59835d411a1` ([live](https://www.notion.so/Wrangle-Roadmap-2026-05-17-363884ec362181e89487c59835d411a1)). Parent for fresh date-stamped siblings: `354884ec-3621-8153-9a94-df74037d2a33` (🛠️ Active Work — Pilot Sprint).

**Don't hard-code the date.** Detect via `ls -d docs/operations/roadmap-*/ | sort | tail -1`. The directory rolls forward when a fresh cluster-shape pass runs.

## Notion access

- Subprocess MCP at `.mcp.json` (gitignored, token pulled from git history). Tools appear under `mcp__notion__*` after Claude Code restart.
- While MCP is unavailable, use raw REST against `https://api.notion.com/v1` with the token from `.mcp.json`. Helpers in `scripts/notion_helpers.py`.

## Notion approval

Three rules — narrower than the parent `wrangle-notion-capture` Phase 4 because this skill operates on a single named mirror page the user has already authorized:

- **Routine in-place edits on the mirror page** (`363884ec-3621-81e8-9487-c59835d411a1`): the user's invocation ("update the roadmap" / "fold this in") IS the approval. Show a one-line preview per block edit before the batched write; write on positive ack. Don't round-trip per block.
- **New sibling pages, structural reorders, schema-level changes** (e.g., adding a new top-level section that didn't exist on this date's page; rolling the doc forward to a new dated dir + new mirror page): return to full `wrangle-notion-capture` Phase 4 approval — surface the page-level proposal and wait for explicit confirm.
- **Writes to any other Notion page** (not the active roadmap mirror): out of scope for this skill. Invoke `/wrangle-notion-capture` directly.

## Anti-patterns

Don't:

- **Pre-assign issues by name.** The band predicates are predicates over issue shape (label, kind, tech complexity, product-content density), not name-on-issue. Per the project's plot-don't-assign discipline.
- **Sweep unrelated working-tree changes** into the commit. Stage explicit paths: only `roadmap.md` and `jon-working-notes.md`. Run `git status --short` immediately before `git commit` — the pre-commit hook does not protect against staged non-`.md` files getting through.
- **Echo the Notion token** to shell output, commit messages, or chat. Load via `notion_helpers.client()` which keeps it scoped to a function; never `cat .mcp.json` (the rotation incident in commit `4d29a4e4` traces back to this).
- **Hard-code the mirror page id across roadmap directories.** Today's mirror is `363884ec-...`; the next cluster-shape pass produces a sibling under parent `354884ec-...`. When the active roadmap dir rolls forward, create the new Notion sibling and update SKILL.md + `scripts/notion_helpers.py` together.
- **Write secret values** to Notion or to committed files. The Notion token lives in `.mcp.json` (gitignored).
- **Paraphrase a `wontfix` rationale into the roadmap.** Closed-wontfix issues either disappear from the roadmap or get noted with a one-line rationale + a link to `.out-of-scope/` if a doc was created.
- **Fold an ambiguous band-decision** without asking. Overlap defaults to Jon's pile; if even that's unclear, stop and surface the question.

## Sister skills

- `wrangle-notion-capture` (`.claude/skills/wrangle-notion-capture/SKILL.md`) — canonical Notion write workflow (read-first + house-style + approval boundaries). Cite when adding NEW Notion pages or doing structural reorders; not for in-place block edits on the mirror.
- `triage` (`~/.claude/skills/triage/SKILL.md`, with project-local override at `.claude/skills/triage/`) — matt-pocock issue-state-machine skill that does the label flip BEFORE this skill files the result into the roadmap.
- `local-tracker` (`.claude/skills/local-tracker/SKILL.md`) — issue-tracker + triage-label mapping for Wrangle.

## Deeper material

- [REFERENCE.md](REFERENCE.md) — per-phase walkthrough, band-predicate decision tree, tier rules, Notion API patterns, sanity tests, commit hygiene.
- [scripts/notion_helpers.py](scripts/notion_helpers.py) — reusable Python helpers for the common Notion block ops (`patch_block_rich_text`, `insert_after`, `delete_block`, rich-text builders).

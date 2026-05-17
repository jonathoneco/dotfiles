---
name: to-docs
description: Distill a doc or ADR update from a finding. Writes deep docs (under `docs/`) and ADRs (`docs/architecture/adr/`). Use when a finding has been classified as "promote to doc," or when the user wants to land a learning in project documentation. For root CAPS-doc and skill updates, use `/to-agent` instead.
---

# To Docs

You are distilling a finding into a deep doc under `docs/` or an ADR under `docs/architecture/adr/`. Don't interview — synthesize from what's already in conversation context, the findings ledger, or arg-supplied text.

Refuse and route elsewhere if the target is a root CAPS doc (`CLAUDE.md`, `ARCHITECTURE.md`, `CONTEXT.md`, `DESIGN.md`, `DEVELOPMENT.md`), a skill under `.claude/skills/`, or a command under `.claude/commands/`. Those go through `/to-agent`.

## ADR vs deep doc

- **ADR** — hard-to-reverse decisions with real trade-offs. The thing future contributors need the *why* for: "we chose X over Y, here's what we gave up." Header, status field, sections matching recent ADRs in `docs/architecture/adr/`.
- **Deep doc** — everything else under `docs/`. Patterns, runbooks, integration notes, learnings without a contested alternative. Match the voice and section depth of the existing doc.

If the finding has no contested alternative, it's a deep doc. If it has one and the choice is hard to reverse, it's an ADR.

## Inputs

- **Finding text** — the learning being promoted.
- **Target** — file path or `new-adr`. If omitted, propose a target from finding content and existing doc structure, then return without writing for the caller to confirm.

## Process

1. Read the target. For an existing doc, match its voice and section structure. For a new ADR, read 2–3 recent ADRs to match header/status/sections convention.
2. Locate the insertion point. For existing docs, find the section the finding belongs in; if nothing fits, propose a new section adjacent to the closest related one. For a new ADR, allocate the next number.
3. Draft. Match voice and section depth. New ADRs follow the project template. In-place edits extend without restructuring surrounding content.
4. Write the file. Direct write — overwrite for in-place edits, create for new ADRs.
5. Return a summary: file path, insertion point, lines added/changed.

## Don't

- Commit. The caller commits as a semantic commit (e.g. `chore(docs): promote finding on X to <file>`).
- Update root CAPS docs or skill files — defer to `/to-agent`.
- Decide which findings to promote — the caller already classified.
- Open a PR.
- Filter or rewrite finding text without surfacing the change in the summary.

## When something goes wrong

- **Target ambiguous, no path supplied** → return without writing; surface candidate paths.
- **Target file doesn't exist and isn't flagged as new ADR** → stop. Caller decides whether to create or pick a different target.
- **Finding contradicts existing content** → write the proposed update with both the new claim and a marker referencing the prior content; surface the conflict in the summary so the caller can review before committing.

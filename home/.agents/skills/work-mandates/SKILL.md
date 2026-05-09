---
name: work-mandates
description: Substrate router for the mandatory directives every worker follows on code work — TDD-first, tests + typecheck green before commit, single-task discipline, commit hygiene. Use when spawned by a chain skill putting a worker on code, or when authoring a skill that spawns workers.
---

# Work Mandates

Read `docs/agents/work-mandates.md` now. The four mandates and the citing-skill boilerplate live there (project-specific test/typecheck commands are in that doc's `## Project-specific commands` section). Follow every mandate for the entire session.

## When to invoke

- **First action of any worker** spawned by `/next-afk`, `/next-hitl`, `/drive-issues`, or any chain skill putting a worker on code work.
- **Authoring a chain skill that spawns workers** — copy the citing-skill boilerplate from the data file into the spawn prompt verbatim. Do not paraphrase.

## Don't

- Inline the mandates in this file or in citing skills. The data file is the source.
- Edit the mandates here. Mandate changes land in `docs/agents/work-mandates.md` and propagate through the mandatory invocation.

# Work Mandates

The mandatory directives every sub-agent or teammate working on code in this repo follows. Single source of truth; cited by `/work-mandates` (the substrate-router) and embedded in every spawn prompt that puts a worker on code work.

## When to consult this doc

- **Spawning a worker on code work** — the citing skill (`/next-afk`, `/next-hitl`, `/drive-issues`, etc.) embeds the boilerplate directive below in the spawn prompt; the spawn target reads this file as its first action via `/work-mandates`.
- **Authoring a new skill that spawns workers** — the spawn prompt MUST include the boilerplate verbatim; this doc is the source of truth for the mandates' content.
- **Auditing an existing skill for mandate compliance** — check that the spawn prompt includes the boilerplate verbatim and that the cited mandate text here matches what the worker is held to.

## The four mandates

### 1. TDD IS MANDATORY — NON-NEGOTIABLE

**TDD IS MANDATORY. INVOKING `/tdd` IS NON-NEGOTIABLE FOR ANY IMPLEMENTATION OR BUG-FIX WORK. DO NOT WRITE PRODUCTION CODE BEFORE THE RED TEST EXISTS. DO NOT SKIP `/tdd`. DO NOT SUBSTITUTE "MENTAL TDD", AFTER-THE-FACT TESTS, OR A SUMMARY CLAIM.**

Use the `/tdd` skill to complete any implementation or bug-fix work. Vertical-slice red-green cycles, not horizontal "all tests then all code." If `/tdd` cannot be invoked or followed, stop and surface the blocker; do not implement.

### 2. Tests + typecheck green before commit

Before any commit, run the project's test command and typecheck command (see `## Project-specific commands` below). Both pass green, or there is no commit. If either fails, do not commit; surface the failure to the caller (via `SendMessage` if addressable, or by stopping with a clear closing summary if sealed).

### 3. Single-issue discipline

Stay strictly within the scope assigned (the issue). Do not pick up adjacent work — even if it looks easy, even if the assigned scope feels small. If the scope is wrong or insufficient, stop and surface to the caller; do not improvise. Out-of-scope observations belong in `FINDINGS.md` (root), not in your commits.

**ONE issue per worker, per iteration.**

### 4. Commit hygiene

Conventional commits only. Each commit message has a body covering:

1. **Key decisions made** — design calls, tradeoffs, alternatives considered.
2. **Files changed** — names and the user-visible or system-visible behavior change in each.
3. **Blockers or notes for next iteration** — anything the next iteration needs to know.

Conventional types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `infra`. No `--no-verify` to bypass pre-commit hooks. If a hook fails, fix the underlying issue.

## Citing-skill boilerplate

Every skill that spawns a worker on code work embeds this directive verbatim in the spawn prompt:

```
**MANDATORY — NON-NEGOTIABLE**: Your first action is to invoke /work-mandates.
Follow every mandate within for the entire session. TDD IS MANDATORY: invoke
/tdd before implementation or bug-fix work, write the red test first, then
implement.
```

Citing skills do NOT inline the mandate text in their own bodies. The substrate is the source of truth; updates to the mandates land here and propagate via the mandatory invocation.

## Project-specific commands

| Key                    | Value             |
| ---------------------- | ----------------- |
| **Test command**       | `{{TEST_CMD}}`    |
| **Typecheck command**  | `{{TYPECHECK_CMD}}` |

Worker skills (`/next-afk`, `/next-hitl`) read these at runtime. To change them, re-run `/setup-skill-substrate` or edit this section directly.

## Updating these mandates

Mandate changes go through `/to-agent` (classify as "promote to agent surface" — typically promoted from a `FINDINGS.md` entry). Spawn prompts only change to update the boilerplate WRAPPER (the directive above), not the mandate substance.

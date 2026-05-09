## System

- EndeavourOS (Arch-based), Sway WM, zsh, foot terminal
- Tool versioning via mise (Go, Node, Python)
- Packages: check AUR before compiling from source
- Desktop notifications via notify-send (swaync)

## Git

- Conventional commits: feat:, fix:, chore:, docs:, refactor:, test:, infra:
- Never force push to main/master
- Prefer specific file staging over `git add -A`

## Orientation — read before starting work

Before kicking off **any** task, read the canonical surfaces and form a deep internal understanding of the project's current state, decisions, and direction. The on-disk state is the source of truth; your training data and prior sessions are not.

- **Root CAPS docs** — `CLAUDE.md`, `ARCHITECTURE.md`, `CONTEXT.md`, `DESIGN.md`, `DEVELOPMENT.md`, `AGENTS.md` (whichever the repo carries).
- **`docs/`** — deep docs, ADRs, agent substrate, operations runbooks, incidents.
- **The repo's issue tracker** — open issues for active work, recent closes for context.

Open the files — skimming filenames or recent commits is not enough.

**Delegate sweeps to sub-agents.** Reading `docs/` whole, or any other broad codebase exploration (>3 queries, multi-directory traversals, "find every place that does X", cross-file consistency checks) is a sub-agent job, not a main-thread job. Spawn `Explore` (read-only, fast) for targeted lookups and pattern grepping; spawn `general-purpose` for open-ended multi-step research. Run independent sweeps in parallel — one message, multiple `Agent` tool calls. Brief each agent like a cold colleague: state the goal, the scope, and the expected report shape (e.g. "under 200 words, punch list of what's relevant to <task>"). Synthesize the returned summaries in the main thread; don't re-do the searches yourself.

**Verify before asking.** Before asking the user a clarifying question, search the codebase and read the relevant files in `docs/` and the root CAPS docs. Most "where does X live", "how does Y work", "what's the convention for Z" questions have answers already in the repo. Ask the user only after the search has actually come up empty — and when you do, cite what you already checked so they can correct your search rather than re-explain the answer.

**Grill before scoping non-trivial work.** For non-trivial changes, designs, or open-ended exploration where multiple plausible shapes exist, invoke `/grill-me` first (or `/grill-with-docs` when domain vocabulary is in play). Walk the design tree question-by-question, surface assumptions, name trade-offs, and reach shared understanding before producing a plan or writing code. Recommend an answer per question rather than open-ended asking, and let the user steer. Trivial tweaks, single-file edits, doc fixes, and one-shot answers don't need grilling. Anything that crosses surfaces, requires sequencing, has multiple plausible shapes, or touches load-bearing invariants does — even when the user hasn't asked.

**Switch to plan mode once work is being planned.** As soon as the conversation crosses from "what's going on / what should we do" into "here's how I'd actually do it" — multi-step implementation, file changes across more than one surface, schema/migration work, anything where the user would benefit from reviewing the approach before edits land — call `EnterPlanMode` and present a plan via `ExitPlanMode` for approval. Don't start writing code first and surface a plan retroactively. Trivial single-file tweaks, doc edits, one-shot answers, and pure-research tasks don't need plan mode; everything that touches code in more than one place or is hard to reverse does.

## Error Handling

Never swallow errors. Always fail loudly. If a function catches an error, it must either re-throw or surface it — never `return []`, `return null`, or silently continue. Pipeline retries depend on errors propagating; observability depends on failures being visible.

```typescript
// WRONG — silent failure, no retry, lost data
try {
  return await externalApi.call()
} catch (e) {
  console.error(e)
  return [] // caller thinks success, data is lost
}
```

Catching to add context (`throw new Error('failed to X', { cause: e })`) is fine. Catching to convert one exception type to another is fine. Catching to suppress is the failure mode.

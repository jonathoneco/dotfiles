---
name: swarm-issues
description: Pilot-stage driver. Drives `.workflow/issues/` to empty by spawning a steady-state pool of 3 parallel teammates per issue, each tackling a file-disjoint part. Lead decomposes the issue, assigns parts, spawns teammates with mandatory TDD + test/typecheck directives, recomposes on return. Use when issues benefit from parallel execution (multiple roughly-independent sub-tasks per issue) and the user wants faster pilot completion than sequential `/drive-issues`. Skip when issues are atomic or tightly coupled (use `/drive-issues`), or when running outside tmux.
---

# Swarm Issues

Parallel sibling to `/drive-issues`. Conforms to the stage-driver contract in [local-workflow/shapes.md](../local-workflow/shapes.md). Owns the issue-by-issue execution loop with parallel decomposition and pilot-stage log entries. Does NOT own finding promotion, PR drafting, or cleanup — those belong to `/confirm-done` in the land stage ([local-workflow/boundaries.md](../local-workflow/boundaries.md)).

For each issue, the lead decomposes into ~3 file-disjoint parts and spawns 3 parallel teammates via the Agent tool in addressable mode (per [/teammate](../teammate/SKILL.md)). As teammates return, the lead reads their summaries, logs, and maintains pool size = 3 until parts for the issue run out. Single shared workspace; collision avoidance depends on disjoint file-ownership in the decomposition.

**One issue at a time across the swarm. Three parallel parts within one issue.**

## When to invoke

- Pilot stage entry: `.workflow/issues/` populated, user wants parallel-per-issue execution.
- Continuation of an in-progress pilot run after a tmux iteration spawn.

## Preflight gates

Stop on any failure.

- `[ -n "$TMUX" ]` — running under tmux.
- `.workflow/issues/` exists and contains at least one `[0-9]*.md` file.
- `.workflow/issues/.STOP` does not exist. **Graceful pause:** `touch .workflow/issues/.STOP` from another window halts the next iteration cleanly.
- `git branch --show-current` is not `main`/`master`.
- Working tree clean. Parallel teammates need a clean baseline to commit against.

## Process

### 1. Stage entry

If `.workflow/log.md` lacks an in-progress `stage-entered:pilot` entry, append one (kind=`stage-entered`, actor=`swarm-issues`, envelope only) and commit `chore(log): swarm-issues pilot stage-entered <ts>`. Subsequent iterations within the same pilot run skip this step.

### 2. Pick the next issue

```sh
ls .workflow/issues/[0-9]*.md 2>/dev/null | head -1
```

0 entries → jump to §6 (pilot exit). 1+ entries → the first is the active issue for this iteration.

### 3. Decompose into parts

Read the active issue. Synthesize ~3 file-disjoint parts. Each part conforms to the same scoping discipline that `/next-afk` (via `.claude/commands/afk-issue.md`) enforces:

- **Single task per part.** No fan-out within a part. ONE task only.
- **Tracer-bullet vertical slice.** Each part cuts a small end-to-end path through the layers it touches, not a horizontal slice of one layer.
- **Priority order applies to which parts surface first**: critical bugfixes > dev infrastructure > tracer bullets > polish > refactors.
- **File ownership is disjoint.** Each part claims a non-overlapping set of files. If the issue resists disjoint decomposition, the swarm pattern does not apply; the lead falls back to `/drive-issues` for this issue (logged as a `decision`).

Write each part to a transient scope file:

```
.workflow/issues/<NN>-<slug>.parts/<part-id>.md
```

Each part file declares: **scope** (one paragraph), **file-ownership claim** (explicit list), **exit condition** (predicate), and **handshakes with sibling parts** (if any).

Log a `decision` entry: kind=`decision`, body has the decomposition summary (which parts, which files, which sibling-handshakes).

### 4. Spawn the teammate pool

Spawn three teammates concurrently via the Agent tool in addressable mode (multiple Agent tool calls in one message; each gets a `name` parameter so SendMessage routes correctly). For each part, the prompt is exactly this template (substitute `<NN>`, `<slug>`, `<part-id>`):

```
You are a swarm teammate working on part <part-id> of `.workflow/issues/<NN>-<slug>.md`.

**MANDATORY — NON-NEGOTIABLE**: Your first action is to invoke `/work-mandates`. Follow every mandate within for the entire session. TDD IS MANDATORY: invoke `/tdd` before implementation or bug-fix work, write the red test first, then implement. DO NOT SKIP TDD.

Read your part scope at `.workflow/issues/<NN>-<slug>.parts/<part-id>.md`. Stay strictly within that scope. Do not touch files outside your declared file-ownership claim. If you discover your scope is wrong or you must touch a file outside your claim, stop and SendMessage the lead with the conflict; do not improvise.

Swarm-specific addition to commit hygiene: each commit must reference the part-id (e.g., `feat(swarm-<NN>-<part-id>): <summary>`).

When your part is complete (exit condition met, tests + typecheck green, committed), SendMessage the lead with a closing summary listing files touched, commit SHAs, and any followup.
```

**MANDATORY: this prompt template is stable.** No custom additions per teammate beyond the swarm-specific commit format and the part-scope reference. The `/work-mandates` invocation directive carries the load-bearing TDD, tests/typecheck, single-task, and commit-hygiene rules — updates land there, not here.

**Steady-state pool rule:** When a teammate returns, if unassigned parts remain (or the lead's review surfaced new parts), spawn a replacement teammate immediately on the next part. Pool size stays at 3 until parts for this issue run out.

For each teammate return, log:

```yaml
---
ts: <ISO-8601 UTC>
stage: pilot
kind: swarm-part
actor: swarm-issues
ref: <NN>-<slug> / <part-id>
---
Outcome: completed | conflict | failed
Files touched: <list>
Commits: <shas>
> <teammate's closing summary, verbatim>
```

If a teammate reports `conflict` (scope error or file collision), the lead arbitrates: re-scope the part, re-spawn or reassign. Log a `decision`.

### 5. Recompose and check issue completion

When the pool drains (no parts to assign, all teammates returned), the lead reviews the issue's exit condition against current state:

- **Issue done** → move issue file to `.workflow/issues/done/`, delete `.workflow/issues/<NN>-<slug>.parts/`, log `issue-completed`.
- **More parts surfaced** → loop back to §3 with a new decomposition pass.
- **Stuck** (no progress, conflicts unresolved) → stop. Surface state to user.

Commit §3–§5 log writes in one batch:

```sh
git add .workflow/log.md
git commit -m "chore(log): swarm-issues pilot $(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

### 6. Spawn next iteration or exit pilot

```sh
ls .workflow/issues/[0-9]*.md 2>/dev/null
```

**≥ 1 entry** → spawn fresh tmux window for the next issue, kill current:

```sh
OLD_WIN=$(tmux display-message -p '#{window_id}')
tmux new-window -d "claude '/swarm-issues'"
tmux kill-window -t "$OLD_WIN"
```

**Hard cut after `tmux new-window`. Do not continue executing in the dying window.**

**0 entries** → pilot exit. Append `stage-exited:pilot`, commit, push, kill window:

```sh
git add .workflow/log.md
git commit -m "chore(log): swarm-issues pilot stage-exited $(date -u +%Y-%m-%dT%H:%M:%SZ)"
git push origin HEAD
tmux kill-window -t "$(tmux display-message -p '#{window_id}')"
```

Final message before kill: "Pilot complete. Run `/confirm-done` from this worktree to start land."

## Log writes

| Kind | When | Payload |
|---|---|---|
| `stage-entered` | first iteration of a pilot run | (envelope only) |
| `decision` | per decomposition pass; per arbitration of a `conflict` return | body has decision text |
| `swarm-part` | per teammate return | `ref` = `<NN>-<slug> / <part-id>`; body has outcome + verbatim teammate summary |
| `issue-completed` | issue moved to `done/`, parts/ dir deleted | `ref` = file path |
| `stage-exited` | last iteration before pilot exit | (envelope only) |

Commit cadence: one commit per iteration boundary (end of §5) and one at pilot exit.

## Exit conditions

- `.workflow/issues/[0-9]*.md` count = 0.
- All `.workflow/issues/<NN>-*.parts/` directories deleted.
- `stage-exited:pilot` written, committed, pushed.
- Tmux window killed.

User is now positioned to run `/confirm-done`.

## Don't

- Continue executing after `tmux new-window` in §6. **The spawn IS the handoff.**
- Spawn more than 3 teammates concurrently per issue. **MANDATORY** to cap pool size at 3.
- Allow teammates to share file ownership. **MANDATORY** that decomposition is file-disjoint.
- Patch the per-teammate prompt with custom guidance beyond the template. **MANDATORY** to keep the prompt stable. TDD + tests + typecheck + scope-discipline mandates are load-bearing.
- Skip `/tdd` in any teammate's prompt. **TDD IS MANDATORY AND NON-NEGOTIABLE** for every part; no production code before the red test.
- Commit teammate work without their tests + typecheck green. **MANDATORY** at the teammate level.
- Use `/swarm-issues` on issues that resist file-disjoint decomposition. **MANDATORY** to fall back to `/drive-issues` when decomposition produces < 2 disjoint parts.
- Open a PR or call `/to-pr`. Land-stage delegation; pilot does not.
- Run cleanup. `.workflow/` removal is `/confirm-done`'s responsibility.
- Push to `main` directly.
- Bypass pre-commit hooks with `--no-verify`. If a hook fails, the skill stops.
- Re-run tests or typecheck independently after a teammate reports green. Trust the report.

## When something goes wrong

- Teammate hangs (no SendMessage closing summary) → stop. Surface the stuck part.
- Teammate reports `conflict` repeatedly on the same scope → fall back to `/drive-issues` for this issue. Log a `decision`.
- Two teammates' commits conflict despite disjoint claims → stop. Lead reviews, decides revert or merge, logs a `decision`.
- Decomposition produces fewer than 2 disjoint parts → this issue is not swarm-suitable. Fall back to `/drive-issues`. Log a `decision`.
- `tmux new-window` fails → not in tmux or session is gone. Stop.
- Log commit fails (pre-commit hook) → stop. No `--no-verify`.
- `git push` fails at pilot exit → stop. Surface the error.

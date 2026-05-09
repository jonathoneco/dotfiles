---
name: drive-issues
argument-hint: "[--prd <NN> ...] [--issue <NN>] [--worktree]"
description: Autonomously drive `ready-for-agent` GitHub issues to closed, one issue per fresh tmux window. Picks the next unblocked AFK issue from the scoped queue, locks onto it, calls /next-afk <issue#> until it closes. Scope flags repeat (`--prd 134 --prd 117`) for multi-PRD mode, or use `--issue <NN>` for one issue. Pass `--worktree` to give each issue its own per-issue branch + worktree + PR + CI loop + merge to main; without it, work in the current worktree (one PR per arch branch). HITL issues (`ready-for-human`) are out of scope — use /next-hitl directly. Skip outside tmux.
---

# Drive Issues

You are driving `ready-for-agent` GitHub issues to closed, autonomously, one issue per fresh tmux window. Each iteration: pick one unblocked, scope-filtered AFK issue; lock onto it; drive it to close (and to merged PR if `--worktree`); spawn the next iteration in a fresh window. Two modes — see `## Worktree mode` below. Out-of-scope observations made by the worker accumulate in `FINDINGS.md` at the repo root across iterations.

`ready-for-human` issues are NOT in scope here. They go through `/next-hitl` (operator-invoked) because they need human sign-offs.

## Scope

Read `$ARGUMENTS` and parse:

- `--prd <NN>` (repeatable) — drive only sub-issues of the listed PRDs. Multi-PRD: pass the flag multiple times. Pick query OR-s the parent qualifiers.
- `--issue <NN>` — drive just that one issue. Mutually exclusive with `--prd`.
- `--worktree` — per-issue branch + worktree + PR cycle. See `## Worktree mode`.
- No scope flags — drive ALL open, unblocked `triaged` issues.

The queue automatically excludes issues with unresolved `blocked-by` dependencies (`-is:blocked`).

## Refuse if

- `[ -z "$TMUX" ]` — not in tmux
- `--worktree` AND `git branch --show-current` is NOT `main`/`master` — worktree mode runs from main only
- NOT `--worktree` AND `git branch --show-current` is `main`/`master` — in-place mode runs from an arch worktree only
- The scoped queue is empty (jump to §4 exit)

Iteration windows spawn plain `claude`; harness default governs permission mode.

## 1. Context load

Fresh Claude session. Load: list open `ready-for-agent` issues for scope and recently-closed (`gh issue list ... --state {open,closed}`); recent commits (`git log -10 --stat HEAD`); for each PRD in scope, `gh issue view <PRD#>` for body. Hold in conversation context.

## 2. Pick the issue for this iteration

Build the search qualifier from scope:

- Multi `--prd 117 --prd 134`: `parent-issue:jonathoneco/wrangle#117 parent-issue:jonathoneco/wrangle#134 -is:blocked`
- Single `--prd <NN>`: `parent-issue:jonathoneco/wrangle#<NN> -is:blocked`
- No scope: `-is:blocked`
- `--issue <NN>`: skip pick; verify state is `OPEN` and label is `ready-for-agent` via `gh issue view <NN> --json state,labels`. Refuse if labeled `ready-for-human` — that's a `/next-hitl` job.

```sh
gh issue list --label ready-for-agent --state open --search "<qualifier>" --json number --jq '.[0].number'
```

Empty → §4 exit. Otherwise the picked `<issue#>` is fixed for this iteration.

## 3. Drive the picked issue to close

**In-place mode** (no `--worktree`): loop `/next-afk <issue#>` in the current worktree until `gh issue view <issue#> --json state` returns `CLOSED`. Partial progress is the norm. The worker captures any out-of-scope observations into `FINDINGS.md` before close — those persist across iterations.

**Worktree mode** (`--worktree`): see `## Worktree mode` below for the per-issue branch + PR + CI + merge cycle.

## 4. Spawn next iteration or exit

Re-evaluate the scoped queue (same query as §2). If the next iteration runs in `--worktree` mode, `cd ~/src/<prefix>` (default branch's worktree per `docs/agents/worktrees.md`) before respawning.

**≥ 1 entry** — fresh window, kill current, scope args persist:

```sh
OLD_WIN=$(tmux display-message -p '#{window_id}')
tmux new-window -d "claude '/drive-issues $ARGUMENTS'"
tmux kill-window -t "$OLD_WIN"
```

**0 entries** — surface a final summary (what shipped, what's next). If `FINDINGS.md` exists, surface its current contents inline so the user can route them to `/to-docs` / `/to-agent` ad hoc. Stop.

## Worktree mode

When `--worktree` is set, §3 expands. For the picked `<issue#>`:

1. **Slug + branch + path.** `slug=$(gh issue view <NN> --json title --jq '.title' | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '-' | cut -c1-40 | sed 's/-$//')`; `branch="feat/<NN>-${slug}"`; path per `docs/agents/worktrees.md` (`../<prefix>-feat-<NN>-${slug}`).
2. **Create + enter.** `git worktree add <path> -b <branch> main && cd <path>`. Refuse on path/branch collision; stop the iteration (don't skip silently).
3. **Drive to close.** Loop `/next-afk <issue#>` until `gh issue view <NN> --json state` returns `CLOSED`. Same loop as in-place, just inside the new worktree.
4. **Push + open PR.** `git push -u origin <branch>`; PR body via `/to-pr --base main --prd <parent#>`; `gh pr create --base main --head <branch> --title <…> --body-file …`.
5. **CI fix loop.** Poll `gh pr checks <PR#> --json` until all required green or any failing. On failures: `/next-afk <issue#>` again — worker sees worktree state, open PR, failing checks, and fixes. Re-poll. Cap at 5 fix iterations; stop+surface if exceeded.
6. **Merge.** `gh pr merge <PR#> --squash --delete-branch`. Refuse if `mergeable` is `CONFLICTING` or `reviewDecision` is `CHANGES_REQUESTED`.
7. **Tear down + return.** `cd ~/src/<prefix>` (main's worktree); `git worktree remove <path>`. `FINDINGS.md` from the per-issue worktree was committed onto the feature branch and merged to main in step 6 — already persisted on `main`.

## Don't

- Pass `--prd` or `--issue` to `/next-afk`. `/next-afk` takes positional `<issue#>` only — drive-issues pre-picks.
- Continue executing after `tmux new-window` in §4. The spawn IS the handoff.
- Switch to a different issue mid-iteration. Once §2 picks it, §3 locks on until it closes.
- In `--worktree` mode: open the PR before the issue closes on GitHub. Issue close gates PR open.
- In `--worktree` mode: merge with failing required checks. `gh pr merge` refuses; do not bypass.
- Bypass pre-commit hooks with `--no-verify`. If a hook fails, stop.

## When something goes wrong

- `/next-afk` no closing summary, `tmux new-window` fails, `git worktree add` collides, pre-commit hook fails → stop.
- CI fix loop exceeds 5 iterations → stop, surface PR# + failing check; do NOT merge or tear down.
- `gh pr merge` refuses (conflict, missing review) → stop with PR# surfaced; worktree remains for follow-up.

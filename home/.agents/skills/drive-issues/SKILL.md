---
name: drive-issues
argument-hint: "[--prd <NN> | --issue <NN>]"
description: Autonomously drive triaged GitHub issues to closed, one issue per fresh tmux window. Picks the next unblocked issue from the scoped queue, locks onto it, calls /next-afk <issue#> until it closes, then /triage. Optional scope: `--prd <NN>` (only sub-issues of that PRD) or `--issue <NN>` (just that one issue). Skipping issues blocked by GitHub issue dependencies is automatic. Skip when the user wants HITL on each issue (use /next-hitl directly), or outside tmux.
---

# Drive Issues

You are driving triaged GitHub issues to closed, autonomously, one issue per fresh tmux window. Each iteration: pick one unblocked, scope-filtered issue from the queue, lock onto it, call `/next-afk <issue#>` until that issue closes, run `/triage`, then spawn the next iteration in a fresh window and kill the current one. PR drafting and merge are ad hoc — invoke `/to-pr` and `/from-pr` yourself when ready.

## Scope

Read your invocation argv as `$ARGUMENTS`. Three forms:

- **No arg** — drive all open, unblocked `triaged` issues until empty.
- `--prd <NN>` — drive only sub-issues of GitHub issue `#<NN>` (PRDs are linked via native sub-issues). Loop exits when no unblocked `triaged` sub-issues of that parent remain.
- `--issue <NN>` — drive just that one issue. Loop exits after that issue closes (one iteration).

The queue automatically excludes any issue with an unresolved `blocked-by` dependency (`-is:blocked` qualifier).

Persist the scope across the §4 tmux respawn — the next window inherits it via the same argv.

## Refuse if

- `[ -z "$TMUX" ]` — not in tmux
- The scoped queue is empty (use `## Pick` query below; if empty, exit cleanly with the final summary)
- `git branch --show-current` is `main` or `master`

Iteration windows spawn plain `claude`; the user's harness default governs permission mode.

## 1. Context load

Each iteration starts in a fresh Claude session — the prior window was killed at §4. Before anything else, load context: list open `triaged` issues for the scope and recently-closed issues (`gh issue list --label triaged --state open` and `--state closed --limit 20`, applying scope filter); survey recent commits (`git log -10 --stat HEAD`). If a PRD is in scope, `gh issue view <PRD#>` for its body. Hold these in conversation context; the picked issue's `/next-afk` summaries accumulate on top.

## 2. Pick the issue for this iteration

Pick the next unblocked, scope-filtered issue. The query depends on scope:

- **No arg**: `gh issue list --label triaged --state open --search "-is:blocked" --json number --jq '.[0].number'`
- `--prd <NN>`: `gh issue list --label triaged --state open --search "parent-issue:jonathoneco/wrangle#<NN> -is:blocked" --json number --jq '.[0].number'`
- `--issue <NN>`: `<NN>` directly (skip query; verify state is `OPEN` via `gh issue view <NN> --json state`)

Empty result → queue exhausted, jump to §4 exit. Otherwise, the picked `<issue#>` is fixed for this iteration's loop.

## 3. Drive the picked issue to close + triage

Loop `/next-afk <issue#>` until that issue closes on GitHub. A single call returns when the sub-agent's iteration completes; partial progress on the same issue is the norm.

```
loop:
  invoke /next-afk <issue#>          # sealed sub-agent, one specific issue
  read sub-agent's closing summary
  check: gh issue view <issue#> --json state --jq '.state'
  if CLOSED:
    break
  otherwise (still OPEN, partial progress):
    loop and call /next-afk <issue#> again
```

After the loop breaks, invoke `/triage` with this directive verbatim:

```
Surface anything that needs attention. For each issue, apply your recommendation directly — no waiting for confirmation.
```

New issues captured during the run are normal — the next iteration picks them up if they fall in scope.

## 4. Spawn next iteration or exit

Re-evaluate the scoped queue (same query as §2).

**≥ 1 entry — spawn fresh window, kill current** (passing scope args through):

```sh
OLD_WIN=$(tmux display-message -p '#{window_id}')
tmux new-window -d "claude '/drive-issues $ARGUMENTS'"
tmux kill-window -t "$OLD_WIN"
```

Hard cut after `tmux new-window`. Do not continue executing in the dying window.

**0 entries — exit**: surface a final summary with what shipped and what's next (typically: invoke `/to-pr` to draft a PR body, then `/from-pr` to merge). Stop.

## Don't

- Pass `--prd` or `--issue` to `/next-afk`. `/next-afk` takes a positional `<issue#>` only — you pre-pick.
- Continue executing after `tmux new-window` in §4. The spawn IS the handoff.
- Switch to a different issue mid-iteration. Once §2 picks it, §3 locks on until it closes or the harness gives up.
- Open a PR, call `/to-pr`, run cleanup, or push. The user runs those ad hoc when ready.
- Bypass pre-commit hooks with `--no-verify`. If a hook fails, stop.
- Ask the user when a sub-skill prompts. Pick the best path and proceed.

## When something goes wrong

- `/next-afk` hangs or returns no closing summary → real failure, stop.
- `tmux new-window` fails → not in tmux or session is gone, stop.
- Pre-commit hook fails → stop. No `--no-verify`.
- The picked issue closed without commits referencing it → `/next-afk` summary should have explained; surface the summary and continue to §4.

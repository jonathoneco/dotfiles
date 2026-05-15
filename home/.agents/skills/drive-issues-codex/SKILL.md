---
name: drive-issues-codex
argument-hint: "[--prd <NN> ...] [--issue <NN>] [--max <N>] [--worktree]"
description: Codex-native supervisor for ready-for-agent GitHub issue queues, especially PRD child queues. Use when the user asks Codex to drive issues, run a Codex issue queue, mentions drive-issues-codex, or wants unattended issue execution in Codex.
---

# Drive Issues Codex

Drive `ready-for-agent` GitHub issues from Codex. This is the queue
supervisor. It picks issues, spawns `codex-issue-worker` sub-agents, verifies
outcomes, and keeps looping until the scoped queue is empty, blocked, or capped.

Do not spawn `claude`, do not invoke slash commands, and do not require tmux.

## Arguments

- `--prd <NN>` repeatable: drive open `ready-for-agent` child issues of one or more PRDs.
- `--issue <NN>`: drive exactly one issue.
- `--max <N>`: stop after at most N closed issues. Default: no cap; run until the queue is empty or blocked.
- `--worktree`: create a per-issue worktree/branch/PR flow. Without it, work in the current non-main worktree.

`--issue` is mutually exclusive with `--prd`. `ready-for-human` issues are out
of scope.

## Startup

1. Read `docs/agents/issue-tracker.md`.
2. Read `docs/agents/work-mandates.md` and copy the citing-skill boilerplate into every worker spawn prompt verbatim.
3. If a command needs approval, request the narrowest reusable prefix rule that keeps the run moving.
4. Create a local run log at `.codex/drive-issues/runs/<YYYYMMDD-HHMMSS>.jsonl` when that path is gitignored; otherwise use `/tmp/drive-issues-codex-<repo>-<timestamp>.jsonl`.

## Queue

Build the GitHub queue with `gh issue list`.

- `--issue <NN>`: verify `state=OPEN`, label includes `ready-for-agent`, and label does not include `ready-for-human`.
- `--prd <NN>`: use `--search "parent-issue:jonathoneco/wrangle#<NN> -is:blocked"` for each PRD scope.
- no scope: use `--search "-is:blocked"`.

Pick the first issue returned and lock onto it for that iteration. After each
closed issue, re-query; do not reuse stale queue state.

## Worker Loop

For each picked issue:

1. Record `picked` in the run log.
2. Spawn one Codex worker sub-agent. The worker prompt says to use the `codex-issue-worker` skill for exactly that issue number and passes the `--worktree` mode.
3. Wait for the worker to finish.
4. Verify with `gh issue view <NN> --json state,labels`.
5. If the issue is `CLOSED`, record `closed`, increment the closed count, and re-query the queue.
6. If the issue is still open, spawn one retry worker with the previous failure summary.
7. If the retry returns with the issue still open, record `stalled`, surface the blocker, and move to the next unblocked issue unless `--issue` was used.

The driver does not edit product code. All implementation happens inside the
worker.

## Worktree Mode

Use this only when `--worktree` is passed.

1. Read `docs/agents/worktrees.md` and follow it exactly.
2. Refuse unless the current branch is the default branch declared in that doc.
3. The driver creates or selects the per-issue worktree, then spawns the worker in that worktree.
4. The worker owns code, tests, commit, PR preparation, and issue closure according to `codex-issue-worker`.
5. The driver verifies the issue/PR state after the worker returns.
6. Remove a worktree only after merge and only if clean.

Without `--worktree`, refuse if currently on `main`/`master`; in-place mode is
for an existing arch/feature worktree.

## Stop Conditions

Stop when:

- `--max` closed-issue count is reached.
- The scoped queue has no open unblocked `ready-for-agent` issues.
- `--issue` remains open after one retry.
- The run hits an external approval, secret, production deploy, destructive action, or ambiguous user-owned decision.

When stopping, report closed issues, stalled issues, run-log path, and any
changed `FINDINGS.md`.

## Don't

- Do not spawn `claude`, `tmux`, `/next-afk`, `/afk-issue`, or `/drive-issues`.
- Do not inline or restate logic owned by `codex-issue-worker`, `work-mandates`, `tdd`, `worktrees`, or `to-pr`.
- Do not work `ready-for-human` issues.
- Do not ask the user between issues unless a stop condition requires it.
- Do not skip tests/checks silently.
- Do not commit unrelated dirty work.
- Do not bypass hooks with `--no-verify`.

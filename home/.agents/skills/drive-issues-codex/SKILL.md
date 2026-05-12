---
name: drive-issues-codex
argument-hint: "[--prd <NN> ...] [--issue <NN>] [--max <N>] [--worktree]"
description: Codex-native driver for ready-for-agent GitHub issues, especially PRD child issues. Use when the user asks Codex to drive issues, run a Codex issue queue, or mentions drive-issues-codex.
---

# Drive Issues Codex

Drive `ready-for-agent` GitHub issues from Codex. This is the Codex-native
replacement for the Claude/tmux `/drive-issues` loop; do not spawn `claude`,
do not invoke slash commands, and do not require tmux. The driver picks the
issue; a Codex worker sub-agent drives the issue using the relevant skills.

## Arguments

- `--prd <NN>` repeatable: drive open `ready-for-agent` child issues of one or more PRDs.
- `--issue <NN>`: drive exactly one issue.
- `--max <N>`: stop after at most N issues. Default: 1.
- `--worktree`: create a per-issue worktree/branch/PR flow. Without it, work in the current worktree.

`--issue` is mutually exclusive with `--prd`. `ready-for-human` issues are out of scope.

## Queue

Build the GitHub queue with `gh issue list`.

- `--issue <NN>`: verify `state=OPEN`, label includes `ready-for-agent`, and label does not include `ready-for-human`.
- `--prd <NN>`: use `--search "parent-issue:jonathoneco/wrangle#<NN> -is:blocked"` for each PRD scope.
- no scope: use `--search "-is:blocked"`.

Pick the first issue returned and lock onto it. Do not switch issues mid-run.

## Per-Issue Delegation

1. Read enough issue metadata to verify the picked issue is open, unblocked, and labeled `ready-for-agent`.
2. Spawn one Codex worker sub-agent for the picked issue. Do not implement issue code in the driver session.
3. Tell the worker to use the relevant skills instead of duplicating their logic:
   - `work-mandates` for mandatory coding, test, and commit rules.
   - `tdd` for code changes.
   - `worktrees` when creating, using, or removing worktrees.
   - `to-pr` when opening a PR is part of the run.
4. When the worker returns, verify the issue state with `gh issue view <NN> --json state`.
5. If the issue is still open, either spawn another worker iteration for the same issue or stop and surface the blocker.

## Worktree Mode

Use this only when `--worktree` is passed.

1. Read `docs/agents/worktrees.md` and follow it exactly.
2. Refuse unless the current branch is the default branch declared in that doc.
3. Create a feature branch/worktree for the issue.
4. Spawn the worker sub-agent in that worktree and have it use the relevant skills for the per-issue workflow.
5. Push, open a PR, run/fix checks, and merge only when allowed by repo rules.
6. Remove the worktree only after merge and only if clean.

Without `--worktree`, refuse if currently on `main`/`master`; in-place mode is for an existing arch/feature worktree.

## Looping

After each issue closes, re-query the scoped queue. Continue until `--max` issues have closed or the queue is empty.

When the queue is empty, report that no unblocked `ready-for-agent` issues remain in scope. If `FINDINGS.md` exists and changed, summarize the new findings.

## Don't

- Do not spawn `claude`, `tmux`, `/next-afk`, `/afk-issue`, or `/drive-issues`.
- Do not inline or restate logic owned by `work-mandates`, `tdd`, `worktrees`, or `to-pr`; call those skills from the driver/worker brief as needed.
- Do not work `ready-for-human` issues.
- Do not skip tests/checks silently.
- Do not commit unrelated dirty work.
- Do not bypass hooks with `--no-verify`.
- Do not merge a PR with failing checks, conflicts, or changes requested.

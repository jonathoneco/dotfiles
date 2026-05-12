---
name: drive-issues-codex
argument-hint: "[--prd <NN> ...] [--issue <NN>] [--max <N>] [--worktree]"
description: Codex-native driver for ready-for-agent GitHub issues, especially PRD child issues. Use when the user asks Codex to drive issues, run a Codex issue queue, or mentions drive-issues-codex.
---

# Drive Issues Codex

Drive `ready-for-agent` GitHub issues from Codex. This is the Codex-native
replacement for the Claude/tmux `/drive-issues` loop; do not spawn `claude`,
do not invoke slash commands, and do not require tmux.

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

## Per-Issue Workflow

1. Read the issue body, comments, labels, parent PRD, recent commits, and relevant docs.
2. Load mandatory work rules from `docs/agents/work-mandates.md` when present.
3. If code changes are needed, use TDD: write or update a failing test first unless the issue is docs-only or test-infeasible.
4. Implement exactly the issue. Record out-of-scope findings in `FINDINGS.md` only when they are material and not covered by the issue.
5. Run targeted tests plus the repo's relevant typecheck/lint/check commands.
6. Commit only files touched for the issue, using conventional commit style.
7. Close the issue only when acceptance criteria are met and checks run or a clear blocker is documented.

## Worktree Mode

Use this only when `--worktree` is passed.

1. Read `docs/agents/worktrees.md` and follow it exactly.
2. Refuse unless the current branch is the default branch declared in that doc.
3. Create a feature branch/worktree for the issue.
4. Complete the per-issue workflow in that worktree.
5. Push, open a PR, run/fix checks, and merge only when allowed by repo rules.
6. Remove the worktree only after merge and only if clean.

Without `--worktree`, refuse if currently on `main`/`master`; in-place mode is for an existing arch/feature worktree.

## Looping

After each issue closes, re-query the scoped queue. Continue until `--max` issues have closed or the queue is empty.

When the queue is empty, report that no unblocked `ready-for-agent` issues remain in scope. If `FINDINGS.md` exists and changed, summarize the new findings.

## Don't

- Do not spawn `claude`, `tmux`, `/next-afk`, `/afk-issue`, or `/drive-issues`.
- Do not work `ready-for-human` issues.
- Do not skip tests/checks silently.
- Do not commit unrelated dirty work.
- Do not bypass hooks with `--no-verify`.
- Do not merge a PR with failing checks, conflicts, or changes requested.

---
name: merge-pr
description: "Drive an open PR through merge into its base: picks the PR, verifies review + CI + mergeability, runs `gh pr merge --delete-branch`, and removes the worktree. Use when ready to land a PR with green CI and review."
disable-model-invocation: true
---

# Merge PR

You are driving an open PR through merge into its base and removing its worktree. You do not draft the PR body (`/to-pr`). Default branch via `docs/agents/worktrees.md` § `Project-specific values`.

Run from the default branch's worktree — never from inside the worktree being merged.

## Preflight gates

Stop on any failure.

- `git branch --show-current` is the default branch (read from `docs/agents/worktrees.md`).
- Working tree clean.
- `gh auth status` succeeds.

## Pick the PR

```sh
gh pr list --state open --json number,title,headRefName,isDraft,mergeable,labels
```

0 open → abort. 1 open → show number/title/branch, confirm. N open → numbered list, oldest first, mark `(draft)`; user picks.

## Verify mergeability

```sh
gh pr view <number> --json baseRefName,headRefName,mergeable,statusCheckRollup,reviewDecision
```

Required: `baseRefName` is the default branch; `mergeable` is `MERGEABLE` (refuse on `CONFLICTING`); required status checks pass per `statusCheckRollup` (refuse on fail); `reviewDecision` is `APPROVED` or repo policy permits self-merge. Surface the reason and stop on any refusal.

## Surface the merge plan

Show one final summary before any state change: PR number/title, head/base branches, merge strategy (squash / merge / rebase per repo pattern; ask if unclear), `--delete-branch` (default yes), remove worktree (default ask). Wait for user confirmation.

## Tear-down ordering: worktree-remove BEFORE merge

The ordering is load-bearing. See `docs/agents/worktrees.md` for why (tear-down ordering + recovery sequence). Encode it:

1. Find the head branch's worktree:

   ```sh
   git worktree list --porcelain | awk '/^worktree/{w=$2} /^branch refs\/heads\/'"<head-branch>"'$/{print w}'
   ```

2. If found and user opted to remove: `git worktree remove <path>`. Refuse on uncommitted work; surface the diff.
3. `gh pr merge <number> --<strategy> --delete-branch`.

If keeping the worktree, omit `--delete-branch` and handle remote deletion manually after merge.

## Post-merge

1. `git fetch origin && git pull --ff-only origin <default-branch>`.
2. Verify `git ls-remote origin <head-branch>` is empty. If alive: ask before `git push origin --delete <head-branch>`.
3. Summary: PR URL, merge SHA, worktree state.

## Don't

- Merge a draft PR without flagging it loudly.
- Auto-merge without user confirmation.
- Force-merge over CI failures or bypass pre-merge hooks.

## When something goes wrong

- `gh pr merge` fails → surface error. Likely permissions or check-status drift.
- Worktree removal fails (uncommitted work) → stop. Recovery sequence in `docs/agents/worktrees.md`.

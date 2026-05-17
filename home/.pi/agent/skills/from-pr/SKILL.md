---
name: from-pr
description: Drive a worktree PR through merge into its base. Picks the PR, runs the merge, optionally cleans up the worktree. Run from the merge target's worktree.
disable-model-invocation: true
---

# From PR

You are driving a worktree PR through merge into its base. Run from the merge target's worktree, never from inside the worktree being merged. Tear-down ordering lives in `docs/agents/worktrees.md`.

## 1. Verify caller state

- Current directory holds the merge target's branch (verified after §3 reads `baseRefName`); ask if `git branch --show-current` doesn't match.
- Working tree clean — stash or commit first.
- `gh auth status` succeeds.

## 2. Pick the PR

`gh pr list --state open --json number,title,headRefName,isDraft,mergeable,labels`. 0 open → abort. 1 open → confirm. N open → numbered list, oldest first, mark `(draft)`; user picks by number.

## 3. Read the PR body

`gh pr view <number> --json body,baseRefName,headRefName,mergeable,statusCheckRollup`. Extract:

- **Test plan** — items the merger may want to verify.
- `mergeable` and check status — refuse if `CONFLICTING` or required checks failing, unless overridden.
- The PR's `body` — show the user a brief summary before any local action.

## 4. Switch to the head worktree (if cleanup needed)

If the user wants to handle anything on the head branch before merge (e.g. `FINDINGS.md` left over, last-minute commits), find its worktree:

```sh
git worktree list --porcelain | awk '/^worktree/{w=$2} /^branch refs\/heads\/'<branch>'$/{print w}'
```

Worktree exists → `cd` in, confirm clean, pull `origin/<branch>`. Missing → ask: `git worktree add` or skip.

If `FINDINGS.md` is present at root and not yet promoted (via `/to-docs`/`/to-agent`/manual edits), prompt the user: walk it now, or proceed (FINDINGS.md persists on the branch and into the merge).

## 5. Merge

Show one final summary: PR number/title/branch/base, merge strategy (squash/merge/rebase per repo pattern; ask if unclear), `--delete-branch` (default yes), delete worktree (default ask).

Tear-down ordering when `--delete-branch` AND worktree-removal are both opted: `cd` to merge target's worktree → `git worktree remove <path>` (refuse if uncommitted) → `gh pr merge <number> --<strategy> --delete-branch`. The "why" lives in `docs/agents/worktrees.md`. Keeping the worktree → omit `--delete-branch` and handle remote-deletion manually. If merge fails (conflict, check flapped), surface and stop.

## 6. Post-merge

1. `cd` to the merge target's worktree.
2. `git fetch origin && git pull --ff-only origin <base>`.
3. If §5 already removed the worktree, skip. Otherwise `git worktree remove <path>`.
4. Verify `git ls-remote origin <head-branch>` is empty. If alive, `git push origin --delete <head-branch>` and surface the bug.
5. If the merged branch had a PRD issue and the user wants to close it: `gh issue close <PRD#> --comment "Closed by PR #<N>"`.
6. Summary: PR URL, merge SHA, worktree state.

## Don't

- Run from inside the worktree being merged.
- Merge a draft PR without flagging it loudly.

## When something goes wrong

- **`mergeable` is `CONFLICTING`**: stop. Conflict resolution is the author's job.
- **Worktree has uncommitted work**: stop. Surface the diff.

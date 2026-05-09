# Worktrees

Conventions for git worktrees in this repo: sibling layout, path pattern, branch-naming rules, and the load-bearing tear-down ordering that prevents `gh pr merge --delete-branch` from leaving orphan remote branches.

## When to consult this doc

- **Creating a worktree** — for the path pattern and the create command.
- **Removing a worktree** — for the tear-down ordering (load-bearing; getting it wrong leaves orphan remote branches).
- **Authoring a skill that touches worktrees** (`/merge-pr`, `/from-pr`, `/drive-issues --worktree`) — for the conventions the skill encodes.

## Layout

Worktrees are siblings of the canonical checkout, never nested. One worktree = one branch.

Path: `<parent-dir>/<prefix>-<branch-suffix>`, where `<prefix>` is the project's worktree prefix (declared in `## Project-specific values` below) and `<branch-suffix>` is the branch name with any leading namespace (`arch/`, `feat/`, etc.) flattened to dashes.

Example (this project, prefix `{{PREFIX}}`): branch `arch/learning-skills` → worktree `~/src/{{PREFIX}}-learning-skills/`; branch `feat/119-foo` → `~/src/{{PREFIX}}-feat-119-foo/`.

## Branch naming

- **Arch branch**: `arch/<topic>` — long-running initiative scoped via a PRD issue, landed as a single PR to the default branch.
- **Feature branch**: `feat/<NN>-<slug>` (per-issue PR) or any conventional name; whatever the change calls for.

## Creating a worktree

```sh
git worktree add ../<prefix>-<branch-suffix> -b <branch> <default-branch>
```

(Substitute `<prefix>` and `<default-branch>` from `## Project-specific values` below.)

## Tear-down ordering (load-bearing)

When merging with branch + worktree removal:

1. Cleanup commit on the branch, push to origin.
2. `cd` back to the default branch's worktree.
3. `git worktree remove <worktree-path>` — **before** `gh pr merge --delete-branch`.

### Why the order is load-bearing

`gh pr merge --delete-branch` runs `git branch -d` locally; that fails if any worktree still uses the branch, and on failure `gh` does not delete the remote branch — leaving an orphan remote branch + a stale local worktree.

Recovery if you got the order wrong:

```sh
git worktree remove /path/to/worktree
git branch -d <branch-name>
git push origin --delete <branch-name>
```

`/merge-pr` and `/from-pr` encode this ordering automatically. Manual cleanup uses the recovery sequence above.

## Refusing to remove a worktree with uncommitted work

If `git worktree remove` would discard uncommitted changes, refuse and investigate first. Uncommitted work in a worktree is usually intentional — discarding it silently is the failure mode.

## Project-specific values

| Key                  | Value             |
| -------------------- | ----------------- |
| **Worktree prefix**  | `{{PREFIX}}`      |
| **Default branch**   | `{{DEFAULT_BRANCH}}` |

Skills that touch worktrees (`/merge-pr`, `/from-pr`, `/drive-issues --worktree`) read these values at runtime. To change them, re-run `/setup-skills-substrate` or edit this section directly.

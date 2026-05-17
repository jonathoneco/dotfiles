---
name: worktrees
description: Substrate router for git worktree conventions — sibling layout, project-prefix path pattern, branch naming, load-bearing tear-down ordering. Use when creating, navigating, or removing a worktree, or when authoring a skill that touches worktrees.
---

# Worktrees

Read `docs/agents/worktrees.md`. The conventions live there; this skill is the route. Worktree prefix and default branch are declared in that doc's `## Project-specific values` section.

## Invoke when

- Creating, navigating, or removing a worktree.
- Authoring a skill that creates or removes worktrees (`/merge-pr`, `/from-pr`) — copy the conventions; do not re-derive.
- The user asks where a branch's worktree lives or how to clean one up.

## What's in the data file

- Sibling layout + `<prefix>-<branch-suffix>` path pattern.
- Arch-branch vs feature-branch naming.
- Worktree creation command.
- Tear-down ordering and recovery when it goes wrong.
- The "refuse to remove with uncommitted work" rule.
- Project-specific values (prefix, default branch).

## Don't

Do not inline the conventions here, and do not re-derive the tear-down ordering — it is load-bearing, and getting it wrong leaves orphan remote branches.

---
name: to-pr
argument-hint: "[--prd <NN>] [--base <branch>]"
description: Draft a PR body for the current worktree from the current branch's git history and diff, reconciling PRD/sub-issues when applicable and including ad hoc or unscoped changes. Returns the body text. Use when ready to open a PR for the current branch's work. Does not open the PR, commit, or push.
---

# To PR

You are drafting a PR body for the current worktree. Start from the current branch's git history and diff, then reconcile GitHub PRD/sub-issues when applicable. Include ad hoc or unscoped branch changes even when no issue mentions them. Do NOT interview the user — if the branch evidence doesn't carry enough signal to draft, say so and stop.

You do not open the PR, commit, run cleanup, or push. Those are the user's ad hoc steps.

## Inputs

Work from branch evidence first:

- **Base** — default to `main`; honor `--base <branch>` if passed. Compute the merge base with `git merge-base <base> HEAD`.
- **Commits** — `git log <base>..HEAD --oneline --decorate` plus fuller commit bodies when the oneline is not enough. If empty, stop.
- **Diff** — `git diff <base>...HEAD --stat` and targeted `git diff <base>...HEAD -- <path>` for changed areas needed to understand behavior. Use the diff to catch ad hoc/unscoped changes that do not map to issues.
- **Changed files** — `git diff <base>...HEAD --name-status` to group the PR by delivered behavior, not by issue list.
- **FINDINGS.md** *(optional)* — if present at repo root, read its H2 sections; surface promoted-finding context in Notes.

Then reconcile tracker context when applicable:

- **PRD** — if `--prd <NN>` is passed, read via `gh issue view <NN> --json number,title,body,state,labels`. If no PRD is passed, infer cautiously from branch name, commit messages, issue references in commits, or changed issue-driver artifacts; if not clear, skip PRD-specific sections rather than guessing.
- **PRD sub-issues** *(if PRD scoped)* — query native children with `gh issue list --state all --json number,title,state,labels,body,closedAt --search "parent-issue:jonathoneco/wrangle#<NN>"`. Parent-child is native (GitHub sub-issues), not a body-text convention. Do not filter by workflow labels; PR body reconciliation cares about branch evidence and open/closed child state.
- **Referenced issues** — for issue numbers found in commit messages, branch names, or PRD children, read enough issue context with `gh issue view <NN> --json number,title,state,labels,body,closedAt` to map branch changes to user-visible or system-visible outcomes.

## Reconcile

Use git history and diff as the source of truth for what this branch changes. Cross-check that against any PRD/sub-issue context:

- Branch changes that map to closed PRD children or referenced issues.
- Branch changes that are ad hoc/unscoped and do not map to any issue.
- Closed PRD children that appear unrelated to the branch diff.
- Open PRD children that remain follow-up work, not regressions.
- Commits or diff chunks that suggest scope drift from the PRD.

If reconciliation surfaces severe drift, still write the body from branch evidence but flag the drift prominently in Notes. Never hide ad hoc branch changes just because they were not scoped in a PRD or issue.

## Output

Return body text and proposed title as the closing summary. Do not write to disk.

Title: under 70 characters, project domain glossary, no file paths or line numbers.

Body:

```markdown
> *Drafted by AI from GitHub issues + commit history. Review before merging.*

## Summary

Plain-English description of what this PR delivers, for a reviewer who has not read the PRD. One short paragraph; uses the project's domain glossary.

## What shipped

One bullet per coherent branch-delivered behavior change. Reference `#NN` when a change maps to a GitHub issue; include ad hoc/unscoped branch changes without pretending they were issue-scoped.

## What did NOT ship *(if PRD scoped)*

Open native sub-issues still under the PRD — carved out as follow-up, not regression. If empty or no PRD: omit.

## Out of scope *(if PRD scoped)*

Pulled from the PRD's "Out of Scope" section. If no PRD or section: omit.

## Test plan

- [ ] Specific, runnable verification 1
- [ ] Specific, runnable verification 2

Each entry is runnable — not "tests are green" or "looks right".

## Notes

Anything load-bearing for the reviewer that is not obvious from the diff: surprising decisions, ad hoc/unscoped branch changes, new ADRs, out-of-band migration instructions, FINDINGS.md context worth highlighting. Drift surfaced during reconciliation lands here.
```

## Durability rule

The PR body is a durable artifact. Keep it free of file paths, line numbers, and code snippets. The exception: prototype-derived decision-encoding snippets (e.g. a discriminated-union shape that *is* the decision). When in doubt, prose wins.

## Don't

- Open the PR. The user runs `gh pr create`.
- Commit. The user commits ad hoc.
- Filter or rewrite issue content without surfacing the filter rule in Notes.

## When something goes wrong

- `--prd <NN>` passed but the PRD issue is closed → stop and ask. PRDs typically close after the PR merges.
- `git log <base>..HEAD` is empty → stop. Branch is not ahead of base.

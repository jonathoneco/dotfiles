---
name: to-pr
argument-hint: "[--prd <NN>] [--base <branch>]"
description: Draft a PR body for the current worktree from optional PRD + closed-since-base GitHub issues + commit history + FINDINGS.md (if present). Returns the body text. Use when ready to open a PR for the current branch's work. Does not open the PR, commit, or push.
---

# To PR

You are drafting a PR body for the current worktree. Synthesize from GitHub issues, commit history, and `FINDINGS.md` (root, if present). Do NOT interview the user — if the inputs don't carry enough signal to draft, say so and stop.

You do not open the PR, commit, run cleanup, or push. Those are the user's ad hoc steps.

## Inputs

- **PRD** *(optional)* — if `--prd <NN>` is passed, read via `gh issue view <NN> --json body`. Otherwise skip the PRD reference.
- **Closed slices** — `gh issue list --label triaged --state closed --json number,title,body,closedAt --search "closed:>=<base-merge-date>"` for issues closed since the branch diverged from `<base>`.
- **Open `triaged` slices** *(if PRD scoped)* — `gh issue list --label triaged --state open --json number,title --search "parent-issue:jonathoneco/wrangle#<NN>"`. Parent-child is native (GitHub sub-issues), not a body-text convention.
- **Commits + diff** — `git log <base>..HEAD --oneline` and `git diff <base>...HEAD --stat`. Default base is `main`; honor `--base <branch>` if passed.
- **FINDINGS.md** *(optional)* — if present at repo root, read its H2 sections; surface promoted-finding context in Notes.

## Reconcile

Cross-check commits against closed slices. Surface drift in Notes:

- Closed slices with no matching commit.
- Commits with no matching closed slice.

If reconciliation surfaces severe drift (more than half of closed slices lack commits, or vice versa), write the body but flag the drift prominently in Notes.

## Output

Return body text and proposed title as the closing summary. Do not write to disk.

Title: under 70 characters, project domain glossary, no file paths or line numbers.

Body:

```markdown
> *Drafted by AI from GitHub issues + commit history. Review before merging.*

## Summary

Plain-English description of what this PR delivers, for a reviewer who has not read the PRD. One short paragraph; uses the project's domain glossary.

## What shipped

One bullet per closed GitHub issue from this branch's run. Each references the issue by `#NN` and states the user-visible or system-visible behavior change.

## What did NOT ship *(if PRD scoped)*

Open issues still in the tracker for this PRD — carved out as follow-up, not regression. If empty or no PRD: omit.

## Out of scope *(if PRD scoped)*

Pulled from the PRD's "Out of Scope" section. If no PRD or section: omit.

## Test plan

- [ ] Specific, runnable verification 1
- [ ] Specific, runnable verification 2

Each entry is runnable — not "tests are green" or "looks right".

## Notes

Anything load-bearing for the reviewer that is not derivable from the diff: surprising decisions, new ADRs, out-of-band migration instructions, FINDINGS.md context worth highlighting. Drift surfaced during reconciliation lands here.
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

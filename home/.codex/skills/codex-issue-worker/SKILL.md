---
name: codex-issue-worker
argument-hint: "<issue#> [--worktree] [--retry-summary <text>]"
description: Works exactly one ready-for-agent GitHub issue to completion inside Codex. Use only from drive-issues-codex or when the user explicitly asks Codex to work one issue end-to-end with the Codex issue worker.
---

# Codex Issue Worker

Work exactly one GitHub issue. The caller picks the issue; this worker does not
choose or switch issues.

## First Actions

**MANDATORY — NON-NEGOTIABLE**: Your first action is to invoke /work-mandates.
Follow every mandate within for the entire session. TDD IS MANDATORY: invoke
/tdd before implementation or bug-fix work, write the red test first, then
implement.

Then:

1. Read `docs/agents/issue-tracker.md`.
2. Read the issue body and comments with `gh issue view <issue#> --comments`.
3. Verify the issue is open, has `ready-for-agent`, lacks `ready-for-human`, and is not blocked.
4. Inspect recent commits relevant to the touched area before editing.
5. If `--worktree` is present, read `docs/agents/worktrees.md` and operate only in the assigned worktree.

## Work Loop

1. Restate the issue's trigger surface and observable outcome in your own notes.
2. Use `tdd` for any implementation or bug-fix work.
3. Keep scope to the assigned issue. Capture adjacent findings in `FINDINGS.md` or a follow-up issue only when the repo convention requires it.
4. Run the project test and typecheck commands from `docs/agents/work-mandates.md` before committing.
5. Commit only files you touched, using a conventional commit with the required body.
6. If a PR is required, use `to-pr` to prepare the PR body and follow repo PR rules.
7. Close the issue only after the observable outcome is satisfied and verification is green.

## Retry Context

If `--retry-summary` is passed, start by reading it and checking the current
worktree, issue, PR, and failing checks. Do not repeat completed work; continue
from the existing state.

## Closing Summary

Return a concise structured summary:

- `issue`: `#NN`
- `state`: `closed`, `open-blocked`, or `open-needs-human`
- `commit`: commit hash or `none`
- `pr`: PR number or `none`
- `verification`: commands run and result
- `blocker`: only if not closed

## Don't

- Do not pick a different issue.
- Do not work `ready-for-human` issues.
- Do not skip `work-mandates` or `tdd` for code changes.
- Do not ask for user input unless blocked by secrets, production writes, destructive actions, or human-owned product decisions.
- Do not commit unrelated dirty work.
- Do not bypass hooks with `--no-verify`.

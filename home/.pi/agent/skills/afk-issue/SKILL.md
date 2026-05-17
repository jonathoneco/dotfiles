---
name: afk-issue
description: Pi skill version of the old afk-issue command. Selects and works one AFK issue from `.workflow/issues/`, using repo context and recent commits, with mandatory work mandates, TDD, checks, commit hygiene, and issue move-to-done on completion. Use only inside a teammate Pi pane spawned by /skill:next-afk or /skill:drive-issues.
---

# AFK Issue

Run `bash ralph/next-afk-context.sh` to load open issues and the last 5 commits. The output is your input — parse it.

## Work mandates

**MANDATORY — NON-NEGOTIABLE**: Your first action after reading this prompt is to load `/skill:work-mandates`. Follow every mandate within for the entire session. TDD IS MANDATORY: invoke `/skill:tdd` before implementation or bug-fix work, write the red test first, then implement. DO NOT SKIP TDD.

## Issues

Local issue files from `.workflow/issues/` are provided as context. Parse them to understand the open issues.

Work on AFK issues only, not HITL ones. Respect `.workflow/issues/.SCOPE` if present; `ralph/next-afk-context.sh` should already filter by it.

If all AFK tasks are complete, write `<promise>NO MORE TASKS</promise>` in your closing summary.

## Task selection

Pick the next task. Prioritize tasks in this order:

1. Critical bugfixes
2. Development infrastructure
3. Tracer bullets for new features
4. Polish and quick wins
5. Refactors

Tracer bullets are small slices of functionality that go through all layers of the system, allowing the approach to be tested early.

## Exploration

Explore the repo.

## The issue

Work exactly one issue.

If the task is complete, move the issue file to `.workflow/issues/done/`.

If the task is not complete, add a note to the issue file with what was done.

Do not start non-Pi harness commands (`claude`, `claude-code`) or legacy command paths. Use Pi skill commands only.

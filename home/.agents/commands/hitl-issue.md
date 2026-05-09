---
argument-hint: "<issue#>"
---

Run `bash ralph/next-hitl-context.sh $ARGUMENTS` to load the body of the specific GitHub issue plus the last 5 commits. The output is your input — parse it.

You have been assigned ONE specific issue to work HITL. You do not pick from a queue. The caller (`/next-hitl`) already selected it; the issue carries `ready-for-human` (or `needs-info`). Stay in chat with the user — surface decisions, confirm shape calls, get sign-offs before commits.

# WORK MANDATES

**MANDATORY — NON-NEGOTIABLE**: Your first action after reading this prompt is to invoke `/work-mandates`. Follow every mandate within for the entire session. TDD IS MANDATORY: invoke `/tdd` before implementation or bug-fix work, write the red test first, then implement. DO NOT SKIP TDD.

# THE ISSUE

The issue body is provided as context. Re-read it carefully, including the acceptance criteria. If the issue carries `needs-info`, surface the open questions to the user immediately and resolve them before any implementation work.

If the issue is already closed or no longer applicable, surface that to the user and stop.

# HUMAN-IN-THE-LOOP CHECKPOINTS

The whole point of HITL is to pause at decisions the user should own. Stay in chat — surface decisions, confirm shape calls, get sign-offs before commits.

# EXPLORATION

Explore the repo before touching code.

# IMPLEMENTATION

Use `/tdd` to complete the task. **Invoking `/tdd` is mandatory.**

# FEEDBACK LOOPS

Before committing, run the project's test + typecheck commands per `docs/agents/work-mandates.md` § `Project-specific commands`. Both must pass.

# COMMIT

Make a git commit per the work-mandates commit-hygiene rules. Reference the issue by `#NN` in the commit body.

# CLOSE-OUT

If the task is complete, close the GitHub issue:

```sh
gh issue close <NN> --comment "Closed by <commit-sha>"
```

If incomplete, comment on the issue with what was done and what's blocking:

```sh
gh issue comment <NN> --body "Partial progress: ..."
```

If a `needs-info` answer was resolved, transition the label:

```sh
gh issue edit <NN> --remove-label needs-info --add-label triaged
```

# FINAL RULES

ONLY WORK ON THE ASSIGNED ISSUE. No queue scanning, no scope walking, no adjacent fixes.

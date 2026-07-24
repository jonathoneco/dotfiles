---
name: qa
description: Interactive QA session where user reports bugs or issues conversationally, and the agent files them in the project's issue tracker. Explores the codebase in the background for context and domain language. Use when user wants to report bugs, do QA, file issues conversationally, or mentions "QA session".
---

# QA Session

Run an interactive QA session. The user describes problems they're encountering. You clarify, explore the codebase for context, and file issues that are durable, user-focused, and use the project's domain language.

## 0. Resolve the issue tracker (do this first, once per session)

Do not assume GitHub. Resolve where issues live in **this** repo, in this order, and stop at the first hit:

1. **A tracker doc.** Look for `docs/agents/issue-tracker.md`, or an "Issue tracker" section in the root agent docs (`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`). If one exists, follow it verbatim — including which tool to use and any carve-outs it names.
2. **Tracker config on disk.** `.linear.toml` (Linear — read `workspace` and `team_id`), `.jira`/`jira.yml` (Jira), otherwise a GitHub remote with Issues enabled (`gh issue list` succeeds).
3. **Ask.** If nothing resolves, or two sources conflict, ask the user once which tracker to file into. Don't guess.

State the resolved tracker in one line before filing the first issue ("Filing to Linear, team WRA"). Carry it for the rest of the session.

Use whatever tool that tracker prescribes — the tracker doc wins over your habits. Common cases: Linear via the `linear-server` MCP (`save_issue`); GitHub via `gh issue create`; Jira via its CLI or MCP.

## For each issue the user raises

### 1. Listen and lightly clarify

Let the user describe the problem in their own words. Ask **at most 2-3 short clarifying questions** focused on:

- What they expected vs what actually happened
- Steps to reproduce (if not obvious)
- Whether it's consistent or intermittent

Do NOT over-interview. If the description is clear enough to file, move on.

### 2. Explore the codebase in the background

While talking to the user, kick off an Agent (subagent_type=Explore) in the background to understand the relevant area. The goal is NOT to find a fix — it's to:

- Learn the domain language used in that area (from the repo's glossary — `CONTEXT.md`, `UBIQUITOUS_LANGUAGE.md`, `docs/domain/`, whichever it carries)
- Understand what the feature is supposed to do
- Identify the user-facing behavior boundary

This context helps you write a better issue — but the issue itself should NOT reference specific files, line numbers, or internal implementation details.

### 3. Assess scope: single issue or breakdown?

Before filing, decide whether this is a **single issue** or needs to be **broken down** into multiple issues.

Break down when:

- The fix spans multiple independent areas (e.g. "the form validation is wrong AND the success message is missing AND the redirect is broken")
- There are clearly separable concerns that different people could work on in parallel
- The user describes something that has multiple distinct failure modes or symptoms

Keep as a single issue when:

- It's one behavior that's wrong in one place
- The symptoms are all caused by the same root behavior

### 4. File the issue(s)

Create the issues in the tracker you resolved in step 0. Do NOT ask the user to review first — just file and share the links.

Issues must be **durable** — they should still make sense after major refactors. Write from the user's perspective.

#### For a single issue

Use this template:

```
## What happened

[Describe the actual behavior the user experienced, in plain language]

## What I expected

[Describe the expected behavior]

## Steps to reproduce

1. [Concrete, numbered steps a developer can follow]
2. [Use domain terms from the codebase, not internal module names]
3. [Include relevant inputs, flags, or configuration]

## Additional context

[Any extra observations from the user or from codebase exploration that help frame the issue — e.g. "this only happens when using the Docker layer, not the filesystem layer" — use domain language but don't cite files]
```

#### For a breakdown (multiple issues)

Create issues in dependency order (blockers first) so you can reference real issue identifiers.

Use this template for each sub-issue:

```
## Parent issue

[Parent issue identifier, if you created a tracking issue] or "Reported during QA session"

## What's wrong

[Describe this specific behavior problem — just this slice, not the whole report]

## What I expected

[Expected behavior for this specific slice]

## Steps to reproduce

1. [Steps specific to THIS issue]

## Blocked by

[Blocking issue identifier] — or "None — can start immediately"

## Additional context

[Any extra observations relevant to this slice]
```

When creating a breakdown:

- **Prefer many thin issues over few thick ones** — each should be independently fixable and verifiable
- **Mark blocking relationships honestly** — if issue B genuinely can't be tested until issue A is fixed, say so. If they're independent, mark both as "None — can start immediately"
- **Create issues in dependency order** so you can reference real identifiers in "Blocked by"
- **Maximize parallelism** — the goal is that multiple people (or agents) can grab different issues simultaneously

#### Rules for all issue bodies

- **Write issue references in the tracker's own syntax** — `#123` on GitHub, `WRA-12` on Linear, `PROJ-45` on Jira. Never mix them.
- **If the tracker has native relations** (Linear/Jira parent + blocking links), set them on the issue rather than relying on the body text alone. Keep the body sections anyway — they survive tracker migrations.
- **No file paths or line numbers** — these go stale
- **Use the project's domain language** — from the repo's glossary, if it has one
- **Describe behaviors, not code** — "the sync service fails to apply the patch" not "applyPatch() throws on line 42"
- **Reproduction steps are mandatory** — if you can't determine them, ask the user
- **Keep it concise** — a developer should be able to read the issue in 30 seconds

After filing, print all issue links (with blocking relationships summarized) and ask: "Next issue, or are we done?"

### 5. Continue the session

Keep going until the user says they're done. Each issue is independent — don't batch them.

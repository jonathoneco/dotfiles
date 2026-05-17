---
name: to-agent
description: Distill an agent-surface update from a finding into root CAPS docs, skill files (`.claude/skills/`), command files (`.claude/commands/`), or `docs/agents/` substrate. Use when a finding is classified "promote to agent surface"; for deep docs use `/to-docs`, for `.claude/settings.json` use `/update-config`.
---

# To Agent

You are distilling a finding into an agent-surface update. Read context, pick the target, write the update in place. No interview.

Scope: root CAPS docs (`CLAUDE.md`, `ARCHITECTURE.md`, `CONTEXT.md`, `DESIGN.md`, `DEVELOPMENT.md`), `.claude/skills/**/*.md`, `.claude/commands/*.md`, `docs/agents/*.md`. Anything in `docs/**` outside `docs/agents/` is `/to-docs`'s. `.claude/settings.json` is `/update-config`'s.

Refuse if you have no finding text — pulled from conversation, an excerpt of the findings ledger, or arg-supplied. Refuse if the caller asks you to decide *whether* to promote; that decision belongs upstream.

## Pick the target

If the caller supplied a path, use it. Otherwise propose one and stop for confirmation. File-pick precedence:

- **`CLAUDE.md`** — baseline rules every session needs. Auto-loads; every line costs.
- **`ARCHITECTURE.md`** — system shape, entity hierarchy, pipeline stages, invariants.
- **`CONTEXT.md`** — domain vocabulary (entities, lifecycle states, system terms).
- **`DESIGN.md`** — visual / executional rules, tokens, components, voice.
- **`DEVELOPMENT.md`** — local dev workflow, test commands, env setup.
- **`.claude/skills/<name>/SKILL.md`** — finding refines an existing skill's behavior.
- **`.claude/commands/<name>.md`** — finding refines a command file.
- **`docs/agents/*.md`** — substrate contracts for matt-pocock or routed skills.

If the finding is detail-level (a deep mechanic, not baseline), stop and route to `/to-docs`. If it's a settings change, stop and route to `/update-config`.

## Write

1. Read the target. Match its voice, section structure, and depth.
2. Find the section the finding belongs in. If none fits, propose a new section adjacent to the closest related one.
3. Apply discipline checks for the target category:
   - **CAPS doc** — confirm baseline-level, not detail. Detail goes to `/to-docs`.
   - **Skill body** — confirm shape conformance (`docs/agents/skill-authoring.md`) and the 100-line cap.
   - **Skill description** — under 1024 chars, two sentences, verb-led.
   - **Command file** — cite `/work-mandates` rather than inlining teammate mandates.
   - **`docs/agents/*`** — stays a contract, not skill body content.
4. Draft the update. Preserve existing user edits — splice in, don't overwrite.
5. Direct write the file.
6. Return: target path, section affected, lines added/changed, discipline-checks passed.

## Don't

- Commit. Caller commits.
- Update `docs/**` outside `docs/agents/`, or ADRs. That's `/to-docs`.
- Edit `.claude/settings.json`. That's `/update-config`.
- Decide which findings to promote. Caller decides.
- Open a PR.
- Skip discipline checks. A skill write that violates shape gets reverted, not landed.
- Filter or rewrite finding text without surfacing the change in the summary.
- Overwrite user edits in the target file. Splice in; preserve what's there.

## When something goes wrong

- **Target ambiguous, no path supplied** → return without writing; surface candidate paths.
- **Discipline check fails** → stop. Surface the violation; let the caller revise the finding or pick a different target.
- **CAPS doc target with detail-level content** → stop. Propose `/to-docs` instead.
- **Finding contradicts existing content** → write the proposed update with both the new claim and a marker referencing the prior content; surface the conflict in the summary.

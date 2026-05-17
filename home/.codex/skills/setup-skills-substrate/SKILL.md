---
name: setup-skills-substrate
description: Scaffold the substrate that the dotfile-tracked workflow skills (`/drive-issues`, `/next-afk`, `/next-hitl`, `/work-mandates`, `/worktrees`, `/write-a-skill`) read at runtime — `docs/agents/worktrees.md`, `docs/agents/work-mandates.md`, `docs/agents/skill-authoring.md`, plus the `ralph/next-{afk,hitl}-context.sh` helpers. Sister to `/setup-matt-pocock-skills` (which scaffolds issue-tracker / triage-labels / domain docs). Run before first use of any of those workflow skills in a fresh project.
disable-model-invocation: true
---

# Setup Skills Substrate

Scaffold the per-repo configuration the workflow skills assume:

- **Worktree conventions** — sibling layout, project-prefix path, branch naming, tear-down ordering
- **Work mandates** — TDD-first, project test + typecheck commands, single-task discipline, commit hygiene
- **Skill authoring discipline** — the rules `/write-a-skill` audits against
- **Ralph context helpers** — `next-afk-context.sh` + `next-hitl-context.sh` for AFK / HITL spawn shapes

Prompt-driven, not deterministic. Explore, present, confirm, write.

## Process

### 1. Explore

Read the current repo's starting state. Don't assume:

- `git remote -v` and `.git/config` — what platform? Issue tracker home?
- `git symbolic-ref refs/remotes/origin/HEAD` — default branch (`main` / `master` / other)
- `package.json` — `scripts.test` and `scripts.typecheck` if present (Node projects)
- `Cargo.toml`, `pyproject.toml`, `go.mod` — non-Node toolchains
- `docs/agents/` — does this skill's prior output already exist? Don't overwrite without asking.
- Repo folder name — default suggestion for worktree prefix

### 2. Present findings, confirm three values

Walk the user through one section at a time. Each section starts with a short explainer, then proposes a default the user can override.

**Section A — Worktree prefix.**

> Explainer: This repo is operated as a fan of sibling worktrees (one branch = one worktree, never nested). The "prefix" is the leading segment of every worktree path — e.g. `wrangle-feat-119-foo` for prefix `wrangle`. `/drive-issues --worktree`, `/merge-pr`, and `/from-pr` all derive worktree paths from this value.

Default: the repo folder's basename. Confirm or override.

**Section B — Default branch.**

> Explainer: Worktree creation, PR merge target, and `--worktree` mode all reference the default branch. Detected via `git symbolic-ref refs/remotes/origin/HEAD`.

Default: detected value. Confirm.

**Section C — Test + typecheck commands.**

> Explainer: `/work-mandates` and `/afk-issue` invoke these before every commit. Both must pass green.

Defaults (in order): `package.json` scripts → `Cargo`/`pyproject` equivalents → ask. Examples: `npm test` / `npm run typecheck`, `cargo test` / `cargo check`, `pytest` / `mypy`.

### 3. Confirm + edit

Show the user a draft of each file before writing. Let them edit. Files:

- `docs/agents/worktrees.md` — from [worktrees.md](./templates/worktrees.md), substitute `{{PREFIX}}` and `{{DEFAULT_BRANCH}}`.
- `docs/agents/work-mandates.md` — from [work-mandates.md](./templates/work-mandates.md), substitute `{{TEST_CMD}}` and `{{TYPECHECK_CMD}}`.
- `docs/agents/skill-authoring.md` — from [skill-authoring.md](./templates/skill-authoring.md), copy verbatim (no substitutions).
- `ralph/next-afk-context.sh` — from [next-afk-context.sh](./templates/next-afk-context.sh), copy verbatim.
- `ralph/next-hitl-context.sh` — from [next-hitl-context.sh](./templates/next-hitl-context.sh), copy verbatim.

If any file already exists, surface the existing content and ask: skip, overwrite, or merge.

### 4. Write + announce

Write the five files. `chmod +x ralph/next-{afk,hitl}-context.sh`. Then add or update a `## Workflow skills` section in `CLAUDE.md` (preferred) or `AGENTS.md` (fallback) — never both, never create one when the other exists. Block shape:

```markdown
## Workflow skills

This repo's substrate for the dotfile-tracked workflow skills lives in `docs/agents/`:

- **Worktrees** — sibling layout, prefix `{{PREFIX}}`, default branch `{{DEFAULT_BRANCH}}`. See `docs/agents/worktrees.md`.
- **Work mandates** — TDD-first; test command `{{TEST_CMD}}`; typecheck `{{TYPECHECK_CMD}}`. See `docs/agents/work-mandates.md`.
- **Skill authoring** — the discipline `/write-a-skill` audits against. See `docs/agents/skill-authoring.md`.

Re-run `/setup-skills-substrate` to update these values.
```

### 5. Done

Tell the user setup is complete and which workflow skills will now find their substrate. Mention sibling `/setup-matt-pocock-skills` if `docs/agents/issue-tracker.md` etc. are still missing.

## Don't

- Pick CLAUDE.md vs AGENTS.md silently. Match what's there; ask if neither exists.
- Overwrite existing `docs/agents/*` files without surfacing the diff.
- Hardcode wrangle-specific paths or vocabulary into the templates — they ship verbatim across projects.

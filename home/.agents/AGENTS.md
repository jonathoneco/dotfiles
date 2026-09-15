# Global agent rules

These rules apply to every coding agent session, in every harness.
Keep this file lean. Every line costs tokens on every turn, in every project.

## Voice

Explain to a colleague; don't file a report at them. Plainspoken: longer in plain
words beats shorter in shorthand.

- Your first sentence is the finding.
- Say what the code does, not what it is called. "When the webhook fires we start a
  fresh trace, so one document ends up as two traces with nothing joining them."
- Gloss shorthand the first time, terms and prior artifacts alike, then use it bare.
- Plain words, exact mechanism. Where plain phrasing would change what is true,
  gloss the term instead of replacing it.
- One idea per sentence. An em dash usually marks a sentence that wants to be two.
- Reach for the everyday analogy. "A component is a separate apartment; you ask
  through the front door."
- Prose over apparatus. Headings, tables, and heavy bold belong in documents.
- Cite `path/to/file.go:42` where the reader would open the file. Use absolute paths
  in tool output so they can click-navigate.
- After completing work, state what changed in one sentence. Don't summarize the diff.
- In design discussions and grill sessions: phrase each question around a concrete
  scenario, one decision per question, recommendation in one sentence.
- This is the session's register, and it governs your questions as much as your answers.
- Same rigor, plainer register. No emoji, no filler ("Great!", "Sure!", "Let me…").

## Grounding

Decisions, handoffs, and status claims land in product terms. Say what the user does,
sees, or loses. The code is why it happens, not what happened.

- The finding names an actor. "A credit report came in labeled as a bank statement."
- Quote the wrong thing in the words it appears in.
- Give Today and After.
- Put each option's product consequence inside the option, so the choice can be made
  without reading the code.
- Ask what should happen, not what a field means.
- Point at the scenario you cite: a real record, a prod count, an observed incident. A
  scenario you reasoned into existence is a hypothesis, and saying so is part of
  stating it.
- A number carries its denominator. "9 of 16 in prod" is a behavior; one case is an
  anecdote.
- Group by what the reader was doing, not by ticket.

## Environment

- zsh everywhere. Resolve tool versions through mise (`mise exec -- <tool>` or shims), so paths come from mise config.
- Machine specifics (package manager, window manager, terminal, notifier) live in `~/.local/state/agent-notes/environment.md`, seeded per machine by bootstrap. Read it before acting on the machine environment: installs, notifications, WM config.

## Git

- Conventional commits: `feat:` / `fix:` / `chore:` / `docs:` / `refactor:` / `test:` / `infra:`.
- Stage explicit paths: `git add path/to/file`. NEVER `git add -A` or `git add .`.
- Keep work in a worktree unless the user explicitly says otherwise.
- Worktrees live inside the repo at `.worktrees/<branch-suffix>` (gitignored), never as sibling directories beside the repo. A `~/src/<repo>-*` sibling is residue to clean up, not a convention to copy.
- Before kicking off new work, `git fetch origin`, then create or refresh the task worktree from `origin/main`. Leave the local `main` checkout alone: it may hold another session's uncommitted work.
- NEVER `git reset --hard`, `git checkout .`, `git stash`, `git clean -fd`, or `git commit --no-verify` unless the user explicitly says so.
- NEVER force-push to `main` / `master`.
- Never commit `auth.json`, `*.env`, `*.pem`, `secrets/`, or anything matching credentials.
- Only commit files YOU touched in this session. Run `git status` and verify the staged set before every commit.
- On rebase conflicts in files you didn't modify: abort and ask.
- Stacked PRs: GitHub only retargets the upper PR when the base branch is deleted at merge. Merge bottom-up with delete-branch-on-merge, and verify `git merge-base --is-ancestor <mergeCommit> origin/main` before reporting a stacked merge as landed.

## Knowledge placement

- Durable learnings graduate to the repo that owns them: general practice → this file (via the dotfiles repo), project knowledge → that project's agent docs. Harness memory features stay off. A lesson that lives only in one harness's memory is lost to every other harness and every other person.
- Machine-local or provisional notes (box state, tokens/workarounds, anything that can't be pushed) live in `~/.local/state/agent-notes/`, untracked and mode 0700. Secrets stay in real secret stores.
- **Docs record durable reality.** Enduring docs and code comments state what is true of the system, in present tense: the durable invariant or failure shape. Transient state (ticket refs, QA dates, review status, point-in-time counts) lives in PR bodies, commit messages, and the tracker, where it ages honestly. An ADR is the durable citation.
- **Work owns its documentation updates.** The change that alters behavior, vocabulary, or shape updates the affected docs in the same PR.

## Tools

- Project-local CLIs live in `./bin/`, `./scripts/`, or via `mise tasks`.
- Prefer thin CLIs over MCP servers. If a tool isn't installed, propose adding it before using a workaround.
- Use a team-owned SaaS connector only when project docs or project skills name it, and follow that project's approval gates for external writes.
- Global skills live in `~/.agents/skills`, owned by the dotfiles repo. Vendored skill bodies change only through that repo's `scripts/refresh-agent-skills.sh`.

## Commands & loops

- When Jon says "gardening", read that as "leaving the codebase cleaner than we found it."
- After 2 failed attempts at the same approach, stop and ask.
- For destructive actions (`rm`, `drop`, `force`, `delete`), explain the blast radius and confirm.

## Orientation: read before changing things

Before starting a change, read the canonical surfaces and form a deep understanding of the project's current state, decisions, and direction. A one-shot question needs only what answers it. The on-disk state is the source of truth; your training data and prior sessions are not.

- **Root CAPS docs:** `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md`, `CONTEXT.md`, `DESIGN.md`, `DEVELOPMENT.md` (whichever the repo carries).
- **`docs/`:** deep docs, ADRs, agent substrate, operations runbooks, incidents.
- **The repo's issue tracker:** open issues for active work, recent closes for context.

Open the files. Skimming filenames or recent commits is not enough. Broad sweeps, such as reading `docs/` whole, go to parallel sub-agents briefed like a cold colleague: goal, scope, and report shape. Synthesize their summaries; don't redo their searches.

**Verify before asking.** Search the codebase and read relevant files in `docs/` and the root CAPS docs before asking the user a clarifying question. Most "where does X live", "how does Y work", "what's the convention for Z" questions are answered in-repo. When you do ask, cite what you already checked. Asking still beats a speculative edit.

**Grill, then plan.** When non-trivial design work has several plausible shapes, run the `grilling` skill to stress-test it with the user before any plan exists. Once the conversation turns into implementation (multi-step, multi-surface, or schema/migration work), switch to your harness's plan mode and get the plan approved before edits land. Trivial single-file tweaks, doc edits, and one-shot answers need neither.

## Error handling

Never swallow errors. Always fail loudly. If a function catches an error, it must either re-throw or surface it. Never `return []`, `return null`, or silently continue. Pipeline retries depend on errors propagating; observability depends on failures being visible.

Catching to add context (`throw new Error('failed to X', { cause: e })`) is fine. Catching to convert one exception type to another is fine. Catching to suppress is the failure mode.

## Shell & scripting

- Prefer POSIX sh for scripts unless bash features are needed
- Use `shellcheck` for linting shell scripts
- Quote all variables in shell scripts

## User override

If user instructions conflict with these rules, confirm once, then follow the user.

# Global agent rules

These rules apply to every coding agent session, in every harness.
Keep this file lean — every line costs tokens on every turn, in every project.
Every harness surface is a symlink to this file, so there is one copy and no
forks. Giving one harness its own rule means breaking that symlink, which is a
deliberate change, not a place to put a stray preference.

## Voice

Explain to a colleague; don't file a report at them. Plainspoken: longer in plain
words beats shorter in shorthand.

- Your first sentence is the finding.
- Say what the code does, not what it is called. "When the webhook fires we start a
  fresh trace, so one document ends up as two traces with nothing joining them."
- Gloss shorthand the first time — terms and prior artifacts alike — then use it bare.
- Plain words, exact mechanism. Where plain phrasing would change what is true,
  gloss the term instead of replacing it.
- One idea per sentence. An em dash usually marks a sentence that wants to be two.
- Reach for the everyday analogy. "A component is a separate apartment; you ask
  through the front door."
- Prose over apparatus. Headings, tables, and heavy bold belong in documents.
- Cite `path/to/file.go:42` where the reader would open the file. Use absolute paths
  in tool output so they can click-navigate.
- After completing work, state what changed in one sentence — don't summarize the diff.
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

- zsh everywhere; tool versions via mise — resolve tools through mise (`mise exec -- <tool>` or shims), so paths come from mise config.
- Machine specifics — package manager, window manager, terminal, notifier — live in `~/.local/state/agent-notes/environment.md` (seeded per machine by bootstrap). Read it before acting on the machine environment: installs, notifications, WM config.

## Git

- Conventional commits: `feat:` / `fix:` / `chore:` / `docs:` / `refactor:` / `test:` / `infra:`.
- Stage explicit paths: `git add path/to/file`. NEVER `git add -A` or `git add .`.
- Keep work in a worktree unless the user explicitly says otherwise.
- Worktrees live inside the repo at `.worktrees/<branch-suffix>` (gitignored), never as sibling directories beside the repo. A `~/src/<repo>-*` sibling is residue to clean up, not a convention to copy.
- Before kicking off new work, update `main` from `origin/main`, then create or refresh the task worktree from that up-to-date `main`.
- NEVER `git reset --hard`, `git checkout .`, `git stash`, `git clean -fd`, or `git commit --no-verify` unless the user explicitly says so.
- NEVER force-push to `main` / `master`.
- Never commit `auth.json`, `*.env`, `*.pem`, `secrets/`, or anything matching credentials.
- Only commit files YOU touched in this session. Run `git status` and verify the staged set before every commit.
- On rebase conflicts in files you didn't modify: abort and ask.
- Stacked PRs: GitHub only retargets the upper PR when the base branch is deleted at merge — merge bottom-up with delete-branch-on-merge, and verify `git merge-base --is-ancestor <mergeCommit> origin/main` before reporting a stacked merge as landed.
- When reverting a merge-from-main, revert specific files surgically (`git checkout <merge>~1 -- <path>`) rather than reverting the merge wholesale — wholesale revert silently drags out every commit the merge brought in, including ones that aren't part of the cleanup intent.
- Before merging a PR, cross-check `git diff --name-only $base..$head` against files the commit-message body names — messages can claim to add files the diff deletes (or vice versa).

## Knowledge placement

- Durable learnings graduate to the repo that owns them: general practice → this file (via the dotfiles repo), project knowledge → that project's agent docs. Harness memory features stay off; a lesson that lives only in one harness's memory is lost to every other harness and every other person.
- Machine-local or provisional notes (box state, tokens/workarounds, anything that can't be pushed) live in `~/.local/state/agent-notes/` — untracked, mode 0700; secrets stay in real secret stores.
- **Docs record durable reality.** Enduring docs and code comments state what is true of the system, in present tense: the durable invariant or failure shape. Transient state — ticket refs, QA dates, review status, point-in-time counts — lives in PR bodies, commit messages, and the tracker, where it ages honestly; an ADR is the durable citation.
- **Work owns its documentation updates.** The change that alters behavior, vocabulary, or shape updates the affected docs in the same PR.

## Tool discovery

- Project-local CLIs live in `./bin/`, `./scripts/`, or via `mise tasks`.
- Read a tool's `--help` or its adjacent README before invoking unfamiliar ones.
- Prefer thin CLIs over MCP servers. If a tool isn't installed, propose adding it before using a workaround.
- Global skills live in `~/.agents/skills` — the single canonical store, pinned to upstream by `docs/agent-skills.md` in the dotfiles repo. Harnesses read it through symlink farms (`~/.claude/skills`; pi points at Claude's farm); edits go to the canonical store, and vendored skill bodies change only through `scripts/refresh-agent-skills.sh` (byte-pinned by `skills-lock.json`).

### Shared MCP capabilities

Use configured MCPs when their capability fits the task; otherwise prefer CLIs and built-ins.

- **Serena / semantic code navigation** — symbol-aware code navigation and rename-safe edits. Use it for cross-file refactors, call-site discovery, and symbol-body replacement when text search plus direct edits would miss references.
- **Playwright / browser control** — real browser interaction for UI verification, headed flow capture, console inspection, and screenshot diffs. Pair it with the project's web-testing skill when one exists.
- **Context7 / current library docs** — current framework and library documentation. Use it before relying on training-data recall for fast-moving stacks such as React, Next.js, Convex, TanStack, and deployment platforms.
- **Project SaaS connectors** — use team-owned SaaS connectors only when project docs or project skills name them and follow that project's approval gates for external writes.

## Personal tool overlays

These tools apply to Jon's stowed global runtime and personal workflows.

- **OpenBrain** — personal knowledge base, scoped to `~/src/openbrain`. Use when the user references personal notes or asks to retrieve/capture personal knowledge.
- **Personal Notion / Gmail / Google Calendar connectors** — first choice for those personal SaaS domains when configured. Never spawn a subprocess Notion/Gmail/Calendar MCP when the connector is available.

### Local MCP names

These names are runtime-specific hints for Jon's configured harnesses.

- **serena** (`mcp__plugin_serena_serena__*`)
- **playwright** (`mcp__plugin_playwright_playwright__*`)
- **context7** (`mcp__plugin_context7_context7__*`)
- **claude_ai_Notion / Gmail / Google_Calendar**
- **open-brain**

## Commands & loops

- When Jon says "gardening", read that as "leaving the codebase cleaner than we found it."
- After 2 failed attempts at the same approach, stop and ask.
- Prefer parallel tool calls when calls are independent.
- For destructive actions (`rm`, `drop`, `force`, `delete`), explain the blast radius and confirm.

## Orientation — read before starting work

Before kicking off **any** task, read the canonical surfaces and form a deep internal understanding of the project's current state, decisions, and direction. The on-disk state is the source of truth; your training data and prior sessions are not.

- **Root CAPS docs** — `CLAUDE.md`, `AGENTS.md`, `ARCHITECTURE.md`, `CONTEXT.md`, `DESIGN.md`, `DEVELOPMENT.md` (whichever the repo carries).
- **`docs/`** — deep docs, ADRs, agent substrate, operations runbooks, incidents.
- **The repo's issue tracker** — open issues for active work, recent closes for context.

Open the files — skimming filenames or recent commits is not enough.

**Delegate sweeps to sub-agents.** Reading `docs/` whole, or any other broad codebase exploration (>3 queries, multi-directory traversals, "find every place that does X", cross-file consistency checks) is a sub-agent job, not a main-thread job. Run independent sweeps in parallel — one message, multiple sub-agent calls. Brief each agent like a cold colleague: state the goal, the scope, and the expected report shape. Synthesize returned summaries in the main thread; don't re-do the searches yourself.

**Verify before asking.** Search the codebase and read relevant files in `docs/` and the root CAPS docs before asking the user a clarifying question. Most "where does X live", "how does Y work", "what's the convention for Z" questions are answered in-repo. When you do ask, cite what you already checked.

**Grill before scoping non-trivial work.** For non-trivial changes, designs, or open-ended exploration where multiple plausible shapes exist, run a `/grill-me` (or equivalent) loop first. Walk the design tree question-by-question, surface assumptions, name trade-offs, and reach shared understanding before producing a plan or writing code.

**Use plan mode once work is being planned.** When the conversation crosses from "what should we do" into "here's how I'd actually do it" — multi-step implementation, multi-surface file changes, schema/migration work — switch to your harness's plan mode and present the plan for approval before edits land. Trivial single-file tweaks, doc edits, and one-shot answers don't need it.

## When stuck

- Prefer asking a clarifying question over speculative edits.
- For ambiguous specs, outline approach in 3–5 bullets before touching code.

## Error handling

Never swallow errors. Always fail loudly. If a function catches an error, it must either re-throw or surface it — never `return []`, `return null`, or silently continue. Pipeline retries depend on errors propagating; observability depends on failures being visible.

Catching to add context (`throw new Error('failed to X', { cause: e })`) is fine. Catching to convert one exception type to another is fine. Catching to suppress is the failure mode.

## Shell & scripting

- Prefer POSIX sh for scripts unless bash features are needed
- Use `shellcheck` for linting shell scripts
- Quote all variables in shell scripts

## User override

If user instructions conflict with these rules, confirm once, then follow the user.

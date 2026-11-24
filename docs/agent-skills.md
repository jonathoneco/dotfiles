# Global agent skills and rules

Every skill and the global rules come from Jon's home repo, checked out at
`~/src/home` ([`jonathoneco/home`](https://github.com/jonathoneco/home)). This
repo carries only the three links that reach it:

| Link | Target | Read by |
|---|---|---|
| `home/.agents/AGENTS.md` | `../../../home/rules/global.md` | every harness, through `home/.claude/CLAUDE.md`, `home/.codex/AGENTS.md` and `home/.pi/agent/AGENTS.md` |
| `home/.agents/skills` | `../../../home/.agents/skills` | Codex, at `~/.agents/skills` |
| `home/.claude/skills` | `../.agents/skills` | Claude Code and Pi, at `~/.claude/skills` (bootstrap step 5) |

`validate.sh` fails when a link reads any other target, and `validate.sh --deployed`
fails when `~/.agents/AGENTS.md` or `~/.claude/skills` resolves outside `~/src/home`.

## Home is a prerequisite

Each machine needs the `~/src/home` checkout; without it the links dangle.
Bootstrap step 4b prints the clone command when it is missing. When it is there,
the step restores the third-party skills pinned in home's `skills-lock.json` into
its `.agents/skills/`, untracked, with
`npx -y skills experimental_install --no-frozen-lockfile -a codex`. The restore
runs unfrozen because the frozen one refuses home's lock ("has no content hash");
the unfrozen one restores every pinned skill and leaves the lock unchanged. The
step prints a NOTE if the lock changes anyway. `-a codex` keeps the skills in
`.agents/skills/` alone; by default the restore also links each into a
`.claude/skills/` folder, and home keeps no `.claude/`. Home's `vendored.md` records where each
third-party skill comes from.

## Changing a skill or rule

A skill or rule changes through a PR in home, and `git pull` in `~/src/home`
brings it to every session on that machine. Home's `scripts/build-rules` builds
`rules/global.md` from its `rules/core.md` and `rules/personal.md`.

Claude Code lists selected skills by name only, with no description, through `skillOverrides` in `home/.claude/settings.json`. This keeps their descriptions out of each prompt. Codex also keeps each name-only skill from firing on its own through `policy: allow_implicit_invocation: false` in its `agents/openai.yaml`. `scripts/check-skills` in `~/src/home` reports any skill where the two harnesses disagree. A change to the overrides reaches a machine's `~/.claude/settings.json` when bootstrap step 5f runs there.

## Codex hook routing and trust

Bootstrap limits the global Git guard to `Bash`, including entries already installed.
Codex carries patch text in `apply_patch.command`, so shell guards require a tool matcher.
When a group also holds another handler, bootstrap keeps that handler's matcher and
puts the guard in its own `Bash` group.

Bootstrap step 5c''' replaces an earlier working-mode entry with home's
`mode/hooks/mode.py` command, so each event runs one working-mode hook.

Bootstrap refreshes approval hashes for repo-owned hook entries after merging them.
This includes the working-mode hooks, Wrangle's guard, the older docs-ping command, and
`scripts/reminders/engine.mjs` at prompt, pretool, and posttool events.
It reads the project hook file in `~/src/wrangle/.codex/hooks.json`; it does not
update the Wrangle checkout or generate that file. Hook entries outside the owned
command list require review through Codex's `/hooks` command.

## Commands the garden skills name

The commands the garden skills name run bare on every machine through `bin/`:
`ob` runs `~/src/openbrain/bin/ob`, and `open-design` reaches garden-pop
through `bin/garden-pop-tool`, which runs the same dispatcher as Hermes's
host-tool bridge.

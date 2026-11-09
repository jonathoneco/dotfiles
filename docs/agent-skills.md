# Global agent skills

The global store is `home/.agents/skills/`. Codex reads it at `~/.agents/skills`, and
`home/.claude/skills/` is a symlink farm over it that bootstrap links to
`~/.claude/skills` for Claude Code and Pi. Which farm links exist is the per-harness
curation; `find-skills` is in the store and left out of the farm.

## Skills from `~/src/skills`

Most of the store is links into a sibling checkout of the public
[`jonathoneco/skills`](https://github.com/jonathoneco/skills) repo at `~/src/skills`:
the hand-written skills, and Matt Pocock's and pstack's skills copied in and edited there.
That repo owns their text, where each came from, and how upstream changes come in. A link reads `../../../../skills/skills/<category>/<name>`.
Six personal skills every session uses, `the-garden`, `executor`, `hermes`, `sandlot`, `artifact-server`, and `mail-and-calendar`, link into
the private [`jonathoneco/skills-personal`](https://github.com/jonathoneco/skills-personal)
checkout at `~/src/skills-personal` instead, as `../../../../skills-personal/skills/personal/<name>`.
That repo also builds `rules/global.md`, which `home/.agents/AGENTS.md` links to. Both
checkouts are prerequisites on each machine; without it the links dangle, which
`validate.sh --deployed` reports. `git pull` in each checkout is how an edit there
reaches every session. A new skill in its engineering, reasoning or knowledge folder
loads only once this repo links it, in the store and the farm; `validate.sh` fails
while one is missing.

The rest of `skills-personal`'s `skills/personal/` loads only in the personal-agent checkout, through
that repo's own `.agents/skills` links.

Claude Code lists selected skills by name only, with no description, through `skillOverrides` in `home/.claude/settings.json`. This keeps their descriptions out of each prompt. Codex also keeps each name-only skill from firing on its own through `policy: allow_implicit_invocation: false` in its `agents/openai.yaml`. `scripts/check-skills` in `~/src/skills` reports any skill where the two harnesses disagree.

## Codex hook routing and trust

Bootstrap limits the global Git guard to `Bash`, including entries already installed.
Codex carries patch text in `apply_patch.command`, so shell guards require a tool matcher.
When a group also holds another handler, bootstrap keeps that handler's matcher and
puts the guard in its own `Bash` group.

Bootstrap refreshes approval hashes for repo-owned hook entries after merging them.
This includes Wrangle's guard, the older docs-ping command, and
`scripts/reminders/engine.mjs` at prompt, pretool, and posttool events.
It reads the project hook file in `~/src/wrangle/.codex/hooks.json`; it does not
update the Wrangle checkout or generate that file. Hook entries outside the owned
command list require review through Codex's `/hooks` command.

## OpenBrain runtime skills

These live with the OpenBrain client and are linked into the store. The sibling
`openbrain` checkout is a prerequisite on each machine.

| Skill | Source |
|---|---|
| manual-capture | `~/src/openbrain/.agents/skills/manual-capture` |

The commands the garden skills name run bare on every machine through `bin/`:
`ob` runs `~/src/openbrain/bin/ob`, and `open-design` reaches garden-pop
through `bin/garden-pop-tool`, which runs the same dispatcher as Hermes's
host-tool bridge.

## Third-party skills copied here

These stay as folders in the store, refreshed by hand from upstream:

| Skill | Upstream |
|---|---|
| find-skills | vercel-labs/skills |
| herdr | ogulcancelik/herdr |
| notion-cli | makenotion/skills; keep the local notes in its `ntn api` section (close stdin on `-d`, block insert `position`) when refreshing |
| plannotator-annotate, plannotator-last, plannotator-review | backnotprop/plannotator, `apps/skills/core/` at `v0.27.18` |
| playwright-cli | microsoft/playwright-cli, `skills/playwright-cli/` at `74354ecc7a43da16d91a9bc54fa8db8283a3fcf5`; pairs with the `@playwright/cli` npm global that `install.sh` installs, and each Herdr pane gets its own browser session from `config/zsh/config/envs` |
| show-me | humanlayer/skills, `plugins/show-me/skills/show-me/` at `4d69d20`; MIT (`LICENSE`) |
| html, html-diagram, html-plan, html-prototype, html-wireframe, one-pager, big-pics-little-words, design-artifact | plannotator/effective-html, `skills/` at `5ce160a`; MIT (`LICENSE`) |
| theme-factory, web-artifacts-builder | anthropics/skills, `skills/<name>/` at `2c5958ecac7cee2b583967a2c4981d0f4a75c579`; Apache-2.0 (`LICENSE.txt` in each skill) |
| write-better, asd-ste100 | plannotator/write-better, `skills/<name>/` at `8f0ed39`; MIT (`LICENSE`) |

All 13 copied skills above are name-only in Claude Code and Codex. `design-artifact` has no `tot` publishing instructions. The two personal skills `guided-review` and `performance-audit` link to `skills-personal`; they are name-only in both harnesses. This PR merges after PR A. Each machine needs bootstrap step 5f after merge so the new overrides reach `~/.claude/settings.json`.

The HyperFrames skills are not installed globally. For a video task, run `npx hyperframes skills update` in that project first.

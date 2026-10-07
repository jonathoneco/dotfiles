# Global agent skills

The global store is `home/.agents/skills/`. Codex reads it at `~/.agents/skills`, and
`home/.claude/skills/` is a symlink farm over it that bootstrap links to
`~/.claude/skills` for Claude Code and Pi. Which farm links exist is the per-harness
curation; `find-skills` is in the store and left out of the farm.

## Skills from `~/src/skills`

Most of the store is links into a sibling checkout of the private
[`jonathoneco/skills`](https://github.com/jonathoneco/skills) repo at `~/src/skills`:
the hand-written skills, Matt Pocock's and pstack's skills copied in and edited there,
and two personal ones every session uses, `the-garden` and `garden-pad-hazards`.
That repo owns their text, where each came from, and how upstream changes come in. A link reads `../../../../skills/skills/<category>/<name>`, so the
checkout is a prerequisite on each machine; without it the links dangle, which
`validate.sh --deployed` reports. `git pull` in `~/src/skills` is how an edit there
reaches every session. A new skill in its engineering, reasoning or knowledge folder
loads only once this repo links it, in the store and the farm; `validate.sh` fails
while one is missing.

The rest of `skills/personal/` loads only in the personal-agent checkout, through
that repo's own `.agents/skills` links.

Claude Code lists `arena`, `hillclimb`, `interrogate`, and `swarm` by name only, with no
description, through `skillOverrides` in `home/.claude/settings.json`, since each starts
several model runs; the index in `home/.agents/AGENTS.md` says when each applies. The
skills repo's README says why.

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
| hyperframes, hyperframes-*, media-use | heygen-com/hyperframes |
| notion-cli | makenotion/skills |
| plannotator-annotate, plannotator-last, plannotator-review | backnotprop/plannotator, `apps/skills/core/` at `v0.27.18` |
| playwright-cli | microsoft/playwright-cli, `skills/playwright-cli/` at `74354ecc7a43da16d91a9bc54fa8db8283a3fcf5`; pairs with the `@playwright/cli` npm global that `install.sh` installs, and each Herdr pane gets its own browser session from `config/zsh/config/envs` |

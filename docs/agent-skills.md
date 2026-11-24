# User rules and skills

`~/src/home` owns the rules in `AGENTS.md` and the skills in `.agents/skills/`.
Until T3 Code opens projects in home, the user rules and skill directories link
there so Claude Code, Codex, and Pi can load them from other repos.

Clone `jonathoneco/home` to `~/src/home` before running `./bootstrap.sh`.
Bootstrap restores the third-party skills pinned in its `skills-lock.json` with
`npx -y skills experimental_install --no-frozen-lockfile`, because a frozen
restore refuses that lock. It prints a note when `~/src/home` or `npx` is
missing, or when the restore changes the lock. Run
`./validate.sh --deployed` to check the installed links.

## Codex hook routing and trust

Bootstrap limits the global Git guard to `Bash` so it doesn't read patch text
in `apply_patch.command` as a shell command. It keeps other handlers under
their original matchers.

Bootstrap merges the user working-mode hooks and replaces working-mode
commands that point to `~/src/skills`. It refreshes approval hashes for owned entries in
`~/.codex/hooks.json`, `~/src/home/.codex/hooks.json`, and
`~/src/wrangle/.codex/hooks.json`. It does not edit the project hook files.
Review other hooks through Codex's `/hooks` command.

## OpenBrain hooks

The `~/src/openbrain` checkout supplies the prompt recall hook for Claude Code
and the Codex wrappers for recall on prompt and after compaction. Bootstrap
links the Claude hook through Stow, then merges and pins the Codex wrappers.
Recall needs the machine-local `~/.config/openbrain/client.env`.

## Commands in `bin/`

`ob` runs `~/src/openbrain/bin/ob`. `open-design` reaches garden-pop through
`bin/garden-pop-tool`, which uses the same dispatcher as the Hermes host-tool
bridge.

# Pi skills tracked in dotfiles

This directory is stowed to `~/.agents/skills` by the existing `home/` stow target in this repo.

Pi automatically discovers skills from:

- `~/.agents/skills/`
- `~/.pi/agent/skills/`
- project-local skill directories

## Recommended workflow

Vend the small set of skills you actually want to keep reproducible across machines into this directory.

Example layout:

```text
home/.agents/skills/
  react-next/
    SKILL.md
  convex/
    SKILL.md
  tanstack-start/
    SKILL.md
```

Each skill should live in its own directory and contain a `SKILL.md` file.

## Syncing third-party skills into dotfiles

Use the helper script:

```bash
sync-agent-skill ~/.agents/skills/some-skill
```

or from another skill source:

```bash
sync-agent-skill ~/.claude/skills/some-skill
```

This copies the skill into:

```text
~/src/dotfiles/home/.agents/skills/<skill-name>
```

Then commit the result to git.

## Notes

- Root `.md` files inside `~/.agents/skills/` are ignored by pi, so this README is safe.
- Prefer reviewing third-party skill contents before committing them here.
- Your existing dotfiles install already stows `home/`, so no extra installer changes are required.

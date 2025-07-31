# AGENTS.md

## Build/Setup
- Run `./bootstrap.sh` to stow dotfiles and set up symlinks.
- Use GNU Stow: `stow --target=DEST DIR` for modular config management.
- No automated build/test; manual validation is standard.

## Lint/Test
- For shell scripts: lint with `shellcheck <script>`, format with `shfmt -i 2 -w <script>`.
- Manual testing: run scripts directly (e.g. `bin/set-wallpaper`).
- Validate config files (TOML, YAML, INI) with their respective tools if available.

## Code Style Guidelines
- **Shell scripts:**
  - Start with `#!/bin/bash` or `#!/bin/sh`.
  - Use `set -e` for error handling.
  - Indent with 2 spaces, avoid tabs.
  - Use lowercase, hyphenated filenames and variables.
  - Double-quote variables and paths.
  - Source scripts with `. script.sh` or `source script.sh`.
- **Config files:**
  - Follow strict TOML/YAML/INI syntax.
  - Use descriptive section/key names.
  - Document non-obvious logic and system-specific tweaks.
- **General:**
  - Modular theming: scripts update multiple configs at once.
  - Plugin management: install via scripts or git clone as needed.
  - Avoid trailing whitespace; add comments for clarity.

## Error Handling
- Use `set -e` in scripts; check exit codes and handle failures gracefully.

---
For agentic coding agents: follow these conventions for new scripts/configs, validate with shellcheck/shfmt, and document system-specific logic. See garden-arch.md for stack details and references.

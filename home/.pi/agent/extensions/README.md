# Pi extensions

These extensions are tracked directly in dotfiles and are intended to be the canonical, reproducible versions for this setup.

## Why these are copied instead of symlinked

Some of these extensions started from pi example extensions, but they are vendored here rather than symlinked to pi's installed example directory.

Reasons:

- dotfiles should be reproducible across machines
- pi install paths and bundled examples may change across versions
- local fixes and customizations should not be overwritten by upstream example changes
- examples are a starting point, not a stable config surface

## Maintenance model

Treat these files as:

- **upstream example** → reference material
- **dotfiles copy** → locally maintained extension

When pi releases new versions, compare against upstream examples as needed, but keep this directory as the source of truth for your environment.

## Known locally maintained example-derived extensions

These are based on pi examples and/or adapted from them:

- `bookmark.ts`
- `custom-footer.ts`
- `dirty-repo-guard.ts`
- `handoff.ts`
- `model-status.ts`
- `notify.ts`
- `preset.ts`
- `protected-paths.ts`
- `session-name.ts`
- `tools.ts`
- `tree-vim-navigation.ts`
- `truncated-tool.ts`
- `plan-mode/`

## Notes

- If an extension needs upstream changes, manually port them into this directory.
- If an extension is purely experimental, prefer keeping it separate until it proves useful.

# Herdr MRU tab and workspace navigation

Date: 2026-07-15. Scope: first-party Herdr documentation/source and the original GitHub repositories that implement the plugins. No configuration was changed.

## Answer

Yes. There are two installable third-party Herdr plugins, one for each requested MRU toggle. Both work without a Herdr core patch: their manifests register an action and focus/close event hooks, persist two stable IDs in their plugin state directory, then invoke Herdr's normal CLI to focus the remembered ID. Herdr explicitly supports this model: plugins are external executable packages, own durable state, receive focus-event hooks, and can invoke the full CLI through `HERDR_BIN_PATH`. [Herdr plugin model](https://herdr.dev/docs/plugins/#overview) · [plugin events and state](https://herdr.dev/docs/socket-api/#plugin-apis)

| Requested behavior | Working implementation | Action | How it works | Maintenance signal |
| --- | --- | --- | --- | --- |
| Last-focused tab | [dantehemerson/herdr-last-tab](https://github.com/dantehemerson/herdr-last-tab) | `dantehemerson.last-tab.toggle` | Records `current_tab_id` and `last_tab_id` from `tab.focused`/`tab.closed`; calls `herdr tab list` and `herdr tab focus <id>`. The core implementation lists tabs across all workspaces when no `--workspace` is supplied, and focusing a tab switches its workspace too, so this is a global tab MRU toggle. [manifest](https://github.com/dantehemerson/herdr-last-tab/blob/main/herdr-plugin.toml) · [implementation](https://github.com/dantehemerson/herdr-last-tab/blob/main/src/lib.rs) · [core tab API](https://github.com/ogulcancelik/herdr/blob/master/src/app/api/tabs.rs) | Young, single commit (2026-07-07), no releases, 1 star and no open issues at research time. Treat it as a small, auditable personal plugin rather than a mature maintained package. |
| Last-focused workspace | [third774/herdr-last-workspace](https://github.com/third774/herdr-last-workspace) | `third774.last-workspace.toggle` | Records `current_workspace_id` and `last_workspace_id` from `workspace.focused`/`workspace.closed`; calls `herdr workspace list` and `herdr workspace focus <id>`. [manifest](https://github.com/third774/herdr-last-workspace/blob/main/herdr-plugin.toml) · [implementation](https://github.com/third774/herdr-last-workspace/blob/main/src/lib.rs) | Young, single commit (2026-06-22), no releases, 9 stars and no open issues at research time. The tab plugin explicitly credits this repository as its basis. [tab-plugin README](https://github.com/dantehemerson/herdr-last-tab/blob/main/README.md) |

Both manifests require Herdr `>= 0.7.0`, build a Rust binary with Cargo, and declare Linux/macOS support. The repositories' READMEs give the normal install path:

```sh
herdr plugin install dantehemerson/herdr-last-tab
herdr plugin install third774/herdr-last-workspace
```

Herdr's GitHub installer clones the repository, previews/runs declared build commands, and registers its manifest; plugins are ordinary unsandboxed code, so pin a revision and review the source before installing. [Official installation and trust guidance](https://herdr.dev/docs/plugins/#install-and-link)

## Suggested bindings (not applied)

The action-binding shape is supported by Herdr's official plugin documentation. Use explicit `shift+l` for the uppercase chord.

```toml
[[keys.command]]
key = "prefix+l"
type = "plugin_action"
command = "dantehemerson.last-tab.toggle"
description = "last tab"

[[keys.command]]
key = "prefix+shift+l"
type = "plugin_action"
command = "third774.last-workspace.toggle"
description = "last workspace"
```

[Official plugin action keybinding reference](https://herdr.dev/docs/plugins/#keybindings)

## Core status

Herdr core currently has a native `last_pane` action only; it is deliberately pane-level and operates across tabs and workspaces. [config source](https://github.com/ogulcancelik/herdr/blob/master/src/config/model.rs) · [current configuration reference](https://herdr.dev/docs/config-reference/)

There is no accepted native workspace-MRU feature in the sources checked. The direct feature request, [#1327](https://github.com/ogulcancelik/herdr/issues/1327), was closed as `not planned`, but the closing comment is process guidance from the contributor bot rather than a product rejection. An earlier core implementation, [PR #708](https://github.com/ogulcancelik/herdr/pull/708), was automatically closed because it lacked prior maintainer approval; it was not merged or product-reviewed. That makes the plugins the practical, no-core-modification route today.

## Limitations

- These are two-entry toggles, not a navigable MRU stack: repeated activation alternates A ↔ B.
- The first activation only seeds state if no prior focus event has been seen; it does not switch.
- A closed remembered resource is cleared, so the action becomes a clean no-op until a new focus pair is recorded.
- They require a local Rust toolchain because the manifests run `cargo build --release`; neither repository publishes a release artifact.

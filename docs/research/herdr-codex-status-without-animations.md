# Accurate Herdr Codex status with Codex animations disabled

Date: 2026-07-15. Scope: Codex CLI `0.144.4` and first-party Herdr documentation/source only. No configuration was changed.

## Answer

Yes: disabling Codex TUI animations removes the precise signal that Herdr's current Codex manifest uses for `working`. This is an implementation mismatch, not an integration-install problem. Codex's Herdr integration reports native session identity only; Herdr deliberately leaves Codex state to screen-manifest detection. [Herdr integrations](https://herdr.dev/docs/integrations/#codex) · [Herdr status authority](https://herdr.dev/docs/agents/#status-authority)

The active upstream Codex manifest classifies `working` only from a Braille spinner in the OSC terminal title. [Current Codex manifest](https://github.com/ogulcancelik/herdr/blob/master/src/detect/manifests/codex.toml) When `tui.animations = false`, Codex `0.144.4` intentionally returns no spinner title segment, so that rule cannot match. [Codex `terminal_title_spinner_text_at`](https://github.com/openai/codex/blob/rust-v0.144.4/codex-rs/tui/src/chatwidget/status_surfaces.rs#L916-L926)

There is no upstream, install-and-forget fix found: the current official manifest has no static run-state rule, and the official Codex integration does not report full lifecycle state. Herdr's supported remedy is a local per-agent manifest override; it takes precedence over bundled and remote manifests and can be reloaded live. [Herdr detection manifests](https://herdr.dev/docs/agents/#detection-manifests)

## Supported workaround

Keep animations disabled. Configure Codex to emit its static `run-state` in the OSC title while retaining `activity` for the existing `Action Required` blocked title:

```toml
# ~/.codex/config.toml
[tui]
animations = false
terminal_title = ["activity", "run-state", "project"]
```

`run-state` is a documented Codex title item. In `0.144.4`, it emits `Starting`, `Working`, `Waiting`, `Thinking`, or `Ready`; it is independent of `animations`. [Title-item definitions](https://github.com/openai/codex/blob/rust-v0.144.4/codex-rs/tui/src/bottom_pane/title_setup.rs#L41-L51) · [Run-state implementation](https://github.com/openai/codex/blob/rust-v0.144.4/codex-rs/tui/src/chatwidget/status_surfaces.rs#L880-L913)

The presence of `activity` does not re-enable normal animation: with animations disabled, its spinner title segment is omitted. It is retained because Codex's `Action Required` title path is enabled only when `activity` is selected; that preserves the manifest's existing strong blocked rule. [Spinner suppression](https://github.com/openai/codex/blob/rust-v0.144.4/codex-rs/tui/src/chatwidget/status_surfaces.rs#L916-L925) · [Blocked-title condition](https://github.com/openai/codex/blob/rust-v0.144.4/codex-rs/tui/src/chatwidget/status_surfaces.rs#L356-L364)

Then copy the current upstream Codex manifest to `~/.config/herdr/agent-detection/codex.toml` and insert this rule after `osc_title_blocked` and before `osc_title_idle`:

```toml
[[rules]]
id = "osc_title_static_working"
state = "working"
priority = 1040
region = "osc_title"
visible_working = true
regex = ['(?:^| \\| )(?:Starting|Working|Waiting|Thinking)(?:$| \\| )']
```

That pattern matches the configured OSC-title field exactly, rather than broad transcript text. Keep all other upstream rules, especially the live permission/question blockers and transcript-viewer rule. A local override replaces the entire manifest, so a partial file would discard those protections. [Current upstream manifest](https://github.com/ogulcancelik/herdr/blob/master/src/detect/manifests/codex.toml) · [Manifest loading and override precedence](https://herdr.dev/docs/agents/#detection-manifests)

Apply and verify it with:

```sh
herdr server reload-agent-manifests
herdr agent explain <codex-pane-id> --json
```

`agent explain` reports the active manifest source, evaluated rules, matched rule, and fallback reason; test while Codex is visibly working and again at its prompt. [Herdr agent diagnostics](https://herdr.dev/docs/agents/#detection-manifests) · [CLI reference](https://herdr.dev/docs/cli-reference/#agent-detection)

## Trade-offs

- This is a supported Herdr extension point, but it is a local maintenance override: remote Codex-manifest improvements will not apply until the local copy is reconciled.
- `Waiting` is intentionally considered `working`: Codex uses it while an active turn waits on a background terminal. [Codex run-state implementation](https://github.com/openai/codex/blob/rust-v0.144.4/codex-rs/tui/src/chatwidget/status_surfaces.rs#L880-L913)
- Codex's native hooks can provide session identity, but Herdr explicitly does not treat them as lifecycle authority because the hooks do not cover every transition. A custom hook-based state reporter would therefore be a new integration, not the supported built-in path. [Herdr status authority](https://herdr.dev/docs/agents/#status-authority)

## Recommendation

Use the static-title plus local-manifest approach. It retains `animations = false`, restores accurate `working` and current blocked detection, and relies only on documented Codex title configuration and Herdr's supported manifest override mechanism. Upstreaming the static rule to Herdr would remove the only long-term maintenance cost.

# Mission: Remote development with cmux and tmux

## Why
Use cmux as the local interface for persistent development and coding-agent sessions running on remote machines, without giving up tmux's resilience when the laptop disconnects.

## Success looks like
- Attach to a remote host and navigate its tmux sessions as native cmux workspaces, tabs, and splits.
- Know which layer owns session persistence and where to create or close sessions.
- Recover cleanly from SSH disconnects and cmux restarts.

## Constraints
- Keep remote tmux as the persistence layer.
- Prefer existing SSH config aliases and minimal additional infrastructure.
- Treat remote tmux support as a cmux beta feature.

## Out of scope
- Replacing remote tmux with a custom session daemon.
- General SSH administration unrelated to cmux.

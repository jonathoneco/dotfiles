# Secrets Directory

Everything in this directory except this README is gitignored (`.gitignore:15`).
Secret *values* never live in the repo; what lives here is the shape of each
file and where the real one belongs on a machine.

## `secrets/tailscale.env`

Tailscale auth key for auto-login. Generate one at
https://login.tailscale.com/admin/settings/keys.

```sh
TS_AUTHKEY=tskey-auth-...
```

## `~/.config/openbrain/client.env`

Not in this directory — the OpenBrain memory client reads its key from its own
runtime path, never from a repo. Mode 0600, in `~/.config/openbrain/`:

```sh
OPENBRAIN_KEY=...                 # the shared MCP_ACCESS_KEY value
OPENBRAIN_URL=https://<project>.supabase.co/functions/v1/agent-memory
OPENBRAIN_WORKSPACE_ID=openbrain  # the Edge Function hard-filters on this
```

`config/zsh/.zshenv` sources it when present, so terminal sessions carry
`OPENBRAIN_KEY`. The three `~/.claude/hooks/openbrain-*.sh` hooks read it
directly. With no key anywhere every hook exits 0 and does nothing, so a
machine without OpenBrain is never broken by them — it just has no memory.

An optional `~/.config/openbrain/recall-gate.json` tunes which prompts earn a
recall: `{"allow_roots": ["~/src"], "keywords": [...], "min_words": 8}`.

The hooks also need `~/src/openbrain` checked out, since they are symlinks into
`integrations/agent-memory-client/`. `bootstrap.sh` warns when it is missing.

## Rules

- Never commit a real secret; keep `chmod 600` on every one of these files.
- A new machine gets these by hand — from the password manager, or copied from
  a machine that already has them.
- Rotate keys periodically.

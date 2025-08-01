# Secrets Directory

This directory contains sensitive configuration files that should not be committed to version control.

## Files

- `tailscale.env` - Contains Tailscale authentication key for auto-login
- `tailscale.env.example` - Template file showing the expected format

## Setup

1. Copy the example file:
   ```bash
   cp tailscale.env.example tailscale.env
   ```

2. Edit `tailscale.env` and replace the placeholder with your actual Tailscale authkey

3. Generate an authkey at: https://login.tailscale.com/admin/settings/keys

## Security

- Never commit actual secret files to git
- Keep permissions restrictive: `chmod 600 *.env`
- Rotate keys regularly
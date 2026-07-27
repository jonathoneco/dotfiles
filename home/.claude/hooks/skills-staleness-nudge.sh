#!/bin/sh
# SessionStart nudge: surface an overdue vendored-skills refresh.
# Reads the last-refresh date from docs/agent-skills.md in the dotfiles repo
# (resolved through the deployed skill-farm symlink) and prints one line when
# it is more than 90 days old. Advisory only — never blocks, never fails.
set -u

farm="$HOME/.claude/skills"
[ -L "$farm" ] || exit 0
manifest=$(readlink "$farm")/../../../docs/agent-skills.md
[ -f "$manifest" ] || exit 0

last=$(sed -n 's/.*Last refresh: \([0-9-]*\).*/\1/p' "$manifest" | head -1)
[ -n "$last" ] || exit 0

if command -v python3 >/dev/null 2>&1; then
  days=$(python3 -c "import datetime,sys; print((datetime.date.today()-datetime.date.fromisoformat(sys.argv[1])).days)" "$last" 2>/dev/null) || exit 0
  if [ "$days" -gt 90 ]; then
    echo "Vendored agent skills last refreshed $last (${days}d ago) — quarterly refresh overdue. Run scripts/refresh-agent-skills.sh in the dotfiles repo (see docs/agent-skills.md)."
  fi
fi
exit 0

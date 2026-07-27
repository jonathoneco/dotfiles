#!/bin/sh
# Superset notify shim, shared by every hook event in settings.json.
# No-ops unless a Superset environment provides the notifier.
[ -n "${SUPERSET_HOME_DIR:-}" ] || exit 0
[ -x "$SUPERSET_HOME_DIR/hooks/notify.sh" ] || exit 0
SUPERSET_AGENT_ID=claude "$SUPERSET_HOME_DIR/hooks/notify.sh" || true

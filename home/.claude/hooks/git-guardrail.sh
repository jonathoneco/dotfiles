#!/bin/sh
# PreToolUse(Bash) guard: hard rail behind the prose git rules in
# ~/.agents/AGENTS.md. Blocks the operations that are never OK for an agent
# to run unprompted, in every permission mode. Exit 2 = block.
set -eu

command=$(jq -r '.tool_input.command // empty')
[ -n "$command" ] || exit 0

block() {
  echo "BLOCKED by git-guardrail: $1 The user must run this themselves (\`! <cmd>\`) if intended." >&2
  exit 2
}

case " $command " in
  *" git "*) ;;
  *) exit 0 ;;
esac

# Bulk staging — always blocked (stage explicit paths instead).
if printf '%s' "$command" | grep -qE 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+add[[:space:]]+([^|;&]*[[:space:]])?(-A|--all|--no-ignore-removal|\.)([[:space:]]|$|[;|&])'; then
  block "bulk 'git add' (-A/--all/.) is banned; stage explicit paths."
fi

# Destructive tree/history operations — always blocked.
if printf '%s' "$command" | grep -qE 'git[[:space:]].*reset[[:space:]]+.*--hard'; then
  block "'git reset --hard' is banned."
fi
if printf '%s' "$command" | grep -qE 'git[[:space:]].*clean[[:space:]]+-[a-zA-Z]*f'; then
  block "'git clean -f' is banned."
fi
if printf '%s' "$command" | grep -qE 'git[[:space:]].*(checkout|restore)[[:space:]]+\.([[:space:]]|$)'; then
  block "'git checkout/restore .' is banned."
fi
if printf '%s' "$command" | grep -qE 'git[[:space:]].*commit[[:space:]]+.*--no-verify'; then
  block "'git commit --no-verify' is banned."
fi

# Force pushes: any spelling to main/master is always blocked; bare force
# flags (-f/--force, or a +refspec) are blocked everywhere because the
# current branch cannot be verified statically; --force-with-lease to a
# non-main ref is allowed (stacked-branch rebases).
if printf '%s' "$command" | grep -qE 'git[[:space:]].*push'; then
  if printf '%s' "$command" | grep -qE '(--force|-[a-zA-Z]*f[a-zA-Z]*[[:space:]]|-[a-zA-Z]*f$|[[:space:]]\+[^[:space:]:]*(main|master))' \
     && printf '%s' "$command" | grep -qE '(main|master)'; then
    block "force-push touching main/master is banned."
  fi
  if printf '%s' "$command" | grep -qE 'push[^|;&]*([[:space:]]-f([[:space:]]|$)|[[:space:]]--force([[:space:]]|$))'; then
    block "bare force-push is banned; use --force-with-lease on a feature branch, or run it yourself."
  fi
  if printf '%s' "$command" | grep -qE 'push[^|;&]*[[:space:]]\+[^[:space:]]'; then
    block "'+refspec' force-push is banned."
  fi
fi

exit 0

#!/bin/sh
# PreToolUse(Bash) guard: hard rail behind the prose git rules in
# ~/.agents/AGENTS.md. Blocks the operations that are never OK for an agent
# to run unprompted, in every permission mode. Exit 2 = block.
set -eu

command=$(jq -r '.tool_input.command // empty')
[ -n "$command" ] || exit 0

# Strip shell quoting before matching so quoted spellings compare equal to what
# they resolve to: ma'in' → main, '.' → ., '-A' → -A, $'main' → main. A banned
# operation mentioned inside a quoted string also matches — over-blocking is
# the correct direction for this guard; the user runs it themselves if intended.
command=$(printf '%s' "$command" | tr -d "'\"\\\\\$")

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
#
# Read from the push segment only, with flags and refs as whole tokens. Matching
# the whole command made `gh pr create --body-file - --base main` chained after
# a plain push read as a force-push to main, and so did any branch whose name
# merely ends in `main` (feat/paid-evals-main).
push_segment=$(printf '%s' "$command" | grep -oE 'git[[:space:]][^|;&]*push[^|;&]*' || true)
if [ -n "$push_segment" ]; then
  if printf '%s' "$push_segment" | grep -qE '([[:space:]](--force[^[:space:]]*|-[a-zA-Z]*f[a-zA-Z]*)([[:space:]]|$)|[[:space:]]\+[^[:space:]])' \
     && printf '%s' "$push_segment" | grep -qE '([[:space:]]|:|\+|refs/heads/)(main|master)([[:space:]]|$)'; then
    block "force-push touching main/master is banned."
  fi
fi
if printf '%s' "$command" | grep -qE 'git[[:space:]].*push'; then
  if printf '%s' "$command" | grep -qE 'push[^|;&]*([[:space:]]-f([[:space:]]|$)|[[:space:]]--force([[:space:]]|$))'; then
    block "bare force-push is banned; use --force-with-lease on a feature branch, or run it yourself."
  fi
  if printf '%s' "$command" | grep -qE 'push[^|;&]*[[:space:]]\+[^[:space:]]'; then
    block "'+refspec' force-push is banned."
  fi
fi

exit 0

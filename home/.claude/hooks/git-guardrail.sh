#!/bin/sh
# PreToolUse(Bash) guard: hard rail behind the prose git rules in
# ~/.agents/AGENTS.md. Blocks the operations that are never OK for an agent
# to run unprompted, in every permission mode. Exit 2 = block.
set -eu

command=$(jq -r '.tool_input.command // empty')
[ -n "$command" ] || exit 0
raw=$command

# Strip shell quoting before matching so quoted spellings compare equal to what
# they resolve to: ma'in' → main, '.' → ., '-A' → -A, $'main' → main.
command=$(printf '%s' "$command" | tr -d "'\"\\\\\$")

block() {
  echo "BLOCKED by git-guardrail: $1 The user must run this themselves (\`! <cmd>\`) if intended." >&2
  exit 2
}

case "$command" in
  *git*) ;;
  *) exit 0 ;;
esac

# Match git command segments, not substrings anywhere. Whole-command matching
# blocked a prompt or PR body that merely mentioned `git reset --hard` when it
# was an argument to another tool (herdr agent prompt, gh pr create --body).
#
# A segment ends at ; | & ( ) ` or a newline. Wrappers that run their argument
# as a command (sh -c, env, xargs, timeout, mise exec, VAR=value, if/then/do)
# are peeled off the front, so `bash -c 'git reset --hard'` is still a git
# segment. A git command behind a tool not in that list is not seen. Heredoc
# lines that start with git are seen, so a brief listing banned commands one
# per line still over-blocks.
git_lines=$(printf '%s\n' "$command" \
  | tr ';|&()`' '\n' \
  | tr '\t' ' ' \
  | tr -s ' ' \
  | sed -E \
      -e 's/^ +//' \
      -e ':strip' \
      -e 's/^([!{]|then|do|else|elif|if|while|until|time|nohup|exec|command|builtin|eval|sudo|env|nice|xargs|timeout|(ba|z|da|k)?sh|mise (exec|x)|[A-Za-z_][A-Za-z0-9_]*=[^ ]*|-[^ ]*|\{\}|[0-9]+[smhd]?)( +|$)//' \
      -e 't strip' \
      -e 's#^[^ ]*/git( |$)#git\1#' \
  | grep -E '^git( |$)' || true)
[ -n "$git_lines" ] || exit 0

main_ref='^(.*:)?\+?(refs/heads/)?(main|master)$'

while IFS= read -r line; do
  [ -n "$line" ] || continue
  set -f
  # shellcheck disable=SC2086 # split the segment into tokens on purpose
  set -- $line
  set +f
  shift

  # Skip git's global options to reach the subcommand.
  while [ $# -gt 0 ]; do
    case $1 in
      -C|-c|--git-dir|--work-tree|--namespace|--config-env)
        shift
        if [ $# -gt 0 ]; then shift; fi
        ;;
      -*) shift ;;
      *) break ;;
    esac
  done
  [ $# -gt 0 ] || continue
  sub=$1
  shift

  case $sub in
    add)
      # Bulk staging is blocked; stage explicit paths instead. -A/--all with
      # explicit pathspecs is explicit-path staging with deletions included,
      # so it is allowed when every pathspec is verifiably narrower than the
      # repo: not . or ./, no :/ or other magic, no absolute, ~ or .. path,
      # no glob or brace, and no $ anywhere in the command (a variable can
      # expand to the root). A dry run (-n/--dry-run) stages nothing.
      all=false dry=false broad=false wide=false paths=0 after=false
      for a in "$@"; do
        if [ "$after" = false ]; then
          case $a in
            --) after=true; continue ;;
            --all|--no-ignore-removal) all=true; continue ;;
            --dry-run) dry=true; continue ;;
            --pathspec-from-file*) wide=true; continue ;;
            --*) continue ;;
            -*)
              case $a in *n*) dry=true ;; esac
              case $a in *A*) all=true ;; esac
              continue
              ;;
          esac
        fi
        paths=$((paths + 1))
        if printf '%s' "$a" | grep -qE '^([./]+|:.*|\*.*)$'; then broad=true; fi
        if printf '%s' "$a" | grep -qE '^[/~]|\.\.|[][{*?]'; then wide=true; fi
      done
      if [ "$dry" = true ]; then continue; fi
      if [ "$broad" = true ]; then
        block "bulk 'git add' (-A/--all/.) is banned; stage explicit paths."
      fi
      if [ "$all" = true ]; then
        case $raw in *'$'*) wide=true ;; esac
        if [ "$paths" -eq 0 ] || [ "$wide" = true ]; then
          block "bulk 'git add' (-A/--all/.) is banned; stage explicit paths."
        fi
      fi
      ;;

    reset)
      for a in "$@"; do
        if [ "$a" = --hard ]; then block "'git reset --hard' is banned."; fi
      done
      ;;

    clean)
      # In git clean, -n/--dry-run wins over -f: nothing is removed.
      force=false dry=false
      for a in "$@"; do
        case $a in
          --force) force=true ;;
          --dry-run) dry=true ;;
          --*) ;;
          -*)
            case $a in *f*) force=true ;; esac
            case $a in *n*) dry=true ;; esac
            ;;
        esac
      done
      if [ "$force" = true ] && [ "$dry" = false ]; then
        block "'git clean -f' is banned."
      fi
      ;;

    checkout|restore)
      # `git restore --staged .` only unstages; it leaves the tree alone.
      whole=false staged_only=false
      for a in "$@"; do
        case $a in
          --staged|-S) staged_only=true ;;
          --worktree|-W) staged_only=false; break ;;
        esac
      done
      if [ "$sub" = checkout ]; then staged_only=false; fi
      for a in "$@"; do
        if printf '%s' "$a" | grep -qE '^([./]+|:/.*)$'; then whole=true; fi
      done
      if [ "$whole" = true ] && [ "$staged_only" = false ]; then
        block "'git checkout/restore .' is banned."
      fi
      ;;

    commit)
      # For commit, -n means --no-verify, not dry run; only --dry-run is one.
      skip=false dry=false
      for a in "$@"; do
        case $a in
          --no-verify) skip=true ;;
          --dry-run) dry=true ;;
          --*) ;;
          -*) if printf '%s' "$a" | grep -qE '^-[aeqsvz]*n'; then skip=true; fi ;;
        esac
      done
      if [ "$skip" = true ] && [ "$dry" = false ]; then
        block "'git commit --no-verify' is banned."
      fi
      ;;

    push)
      # Force pushes: any spelling to main/master is always blocked; bare force
      # flags (-f/--force, or a +refspec) are blocked everywhere because the
      # current branch cannot be verified statically; --force-with-lease to a
      # non-main ref is allowed (stacked-branch rebases). Flags and refs are
      # whole tokens of this push, so `gh pr create --base main` chained after
      # it and a branch merely ending in `main` (feat/paid-evals-main) do not
      # count. -n/--dry-run sends nothing.
      force=false bare=false plus=false to_main=false dry=false
      for a in "$@"; do
        case $a in
          --dry-run) dry=true ;;
          --force) force=true bare=true ;;
          --force-with-lease*) force=true ;;
          --*) ;;
          -*)
            case $a in *f*) force=true bare=true ;; esac
            case $a in *n*) dry=true ;; esac
            ;;
          +?*) force=true plus=true ;;
        esac
        if printf '%s' "$a" | grep -qE "$main_ref"; then to_main=true; fi
      done
      if [ "$dry" = true ]; then continue; fi
      if [ "$force" = true ] && [ "$to_main" = true ]; then
        block "force-push touching main/master is banned."
      fi
      if [ "$bare" = true ]; then
        block "bare force-push is banned; use --force-with-lease on a feature branch, or run it yourself."
      fi
      if [ "$plus" = true ]; then
        block "'+refspec' force-push is banned."
      fi
      ;;
  esac
done <<EOF
$git_lines
EOF

exit 0

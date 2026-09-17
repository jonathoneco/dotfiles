#!/bin/sh
# Claude Code status line: model + git branch + context & rate-limit bars.
# Bars/percentages shift green -> yellow -> red across tunable thresholds, and
# a warning glyph (plus an actionable hint for context) appears at critical.
input=$(cat)

# --- Tunable thresholds (percent) --------------------------------------------
CTX_WARN=70;  CTX_CRIT=85     # context window: warn amber, then red near compact
RATE_WARN=75; RATE_CRIT=90    # 5h session usage: warn amber, then red near limit

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
rate=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Current git branch of the workspace, if any.
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
branch=""
[ -n "$dir" ] && branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)

# ANSI colors
ESC=$(printf '\033')
RESET="${ESC}[0m"; BOLD="${ESC}[1m"; DIM="${ESC}[2m"
CYAN="${ESC}[36m"; MAGENTA="${ESC}[35m"
GREEN="${ESC}[32m"; YELLOW="${ESC}[33m"; RED="${ESC}[31m"

# Color for a percentage against warn/crit thresholds: green / yellow / red.
color_for() { # pct warn crit
    awk -v p="$1" -v w="$2" -v c="$3" -v g="$GREEN" -v y="$YELLOW" -v r="$RED" \
        'BEGIN{ if (p >= c) printf "%s", r; else if (p >= w) printf "%s", y; else printf "%s", g }'
}
# Exit 0 (true) when pct is at/above the critical threshold.
is_crit() { awk -v p="$1" -v c="$2" 'BEGIN{ exit !(p >= c) }'; }

# Build a 20-char progress bar: filled portion in usage color, empty dim.
make_bar() { # pct warn crit
    col=$(color_for "$1" "$2" "$3")
    filled=$(echo "$1" | awk '{f=int($1/5 + 0.5); if(f>20)f=20; if(f<0)f=0; print f}')
    empty=$((20 - filled))
    fbar=""; i=0
    while [ "$i" -lt "$filled" ]; do fbar="${fbar}█"; i=$((i + 1)); done
    ebar=""; i=0
    while [ "$i" -lt "$empty" ]; do ebar="${ebar}░"; i=$((i + 1)); done
    printf '%s%s%s%s%s' "$col" "$fbar" "$DIM" "$ebar" "$RESET"
}

# Render one "label [bar] pct" segment, bolded with a glyph/hint at critical.
segment() { # label pct warn crit hint
    lbl="$1"; pct="$2"; warn="$3"; crit="$4"; hint="$5"
    pint=$(printf '%.0f' "$pct")
    col=$(color_for "$pct" "$warn" "$crit")
    if is_crit "$pct" "$crit"; then
        printf '%s%s%s [%s] %s%s%s%% ⚠%s%s' \
            "$DIM" "$lbl" "$RESET" "$(make_bar "$pct" "$warn" "$crit")" \
            "$BOLD" "$col" "$pint" "$RESET" "${hint:+ ${DIM}${hint}${RESET}}"
    else
        printf '%s%s%s [%s] %s%s%%%s' \
            "$DIM" "$lbl" "$RESET" "$(make_bar "$pct" "$warn" "$crit")" \
            "$col" "$pint" "$RESET"
    fi
}

result="${BOLD}${CYAN}${model}${RESET}"
[ -n "$branch" ] && result="${result}  ${MAGENTA}⎇ ${branch}${RESET}"
result="${result}  $(segment ctx "$ctx" "$CTX_WARN" "$CTX_CRIT" '/compact')"
[ -n "$rate" ] && result="${result}  $(segment 5h "$rate" "$RATE_WARN" "$RATE_CRIT" 'limit near')"

printf '%s' "$result"

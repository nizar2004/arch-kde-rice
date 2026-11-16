#!/usr/bin/env bash
# =============================================================================
#  tui.sh — shared terminal UI for the arch-kde-rice tools
#
#  Catppuccin Mocha TrueColor palette, Unicode box-drawing banners, step badges
#  and a spinner. Uses Charmbracelet `gum` when it is installed and falls back
#  to pure ANSI/Unicode — so nothing breaks on a machine without gum.
#
#  Source it:  . "$(dirname "$(readlink -f "$0")")/lib/tui.sh"
# =============================================================================

# --- palette (Catppuccin Mocha) ----------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-}" != "dumb" ]; then
    C_RESET=$'\e[0m';   C_BOLD=$'\e[1m';   C_DIM=$'\e[2m'
    C_TEXT=$'\e[38;2;205;214;244m'   # cd d6 f4
    C_SUB=$'\e[38;2;166;173;200m'    # a6 ad c8
    C_SURFACE=$'\e[38;2;88;91;112m'  # 58 5b 70
    C_BLUE=$'\e[38;2;137;180;250m'   # 89 b4 fa
    C_MAUVE=$'\e[38;2;203;166;247m'  # cb a6 f7
    C_GREEN=$'\e[38;2;166;227;161m'  # a6 e3 a1
    C_YELLOW=$'\e[38;2;249;226;175m' # f9 e2 af
    C_RED=$'\e[38;2;243;139;168m'    # f3 8b a8
    C_PEACH=$'\e[38;2;250;179;135m'  # fa b3 87
    C_TEAL=$'\e[38;2;148;226;213m'   # 94 e2 d5
    C_LAV=$'\e[38;2;180;190;254m'    # b4 be fe
    COLOR=1
else
    C_RESET=; C_BOLD=; C_DIM=; C_TEXT=; C_SUB=; C_SURFACE=
    C_BLUE=; C_MAUVE=; C_GREEN=; C_YELLOW=; C_RED=; C_PEACH=; C_TEAL=; C_LAV=
    COLOR=0
fi

# gum, when present, powers the spinner and boxes
GUM="$(command -v gum 2>/dev/null || true)"
[ -t 1 ] || GUM=""

# --- primitives --------------------------------------------------------------
_have_col() { [ "$COLOR" -eq 1 ]; }

# visible width of a string (strip ANSI + count chars, not bytes)
_strw() { printf '%s' "$1" | sed 's/\x1b\[[0-9;]*m//g' | wc -m; }
_rep()   { local n="$1" c="$2" s=; for ((i=0;i<n;i++)); do s+="$c"; done; printf '%s' "$s"; }

banner() { # banner <title> [subtitle]
    local title="$1" sub="${2:-}"
    local w=54 i
    local t="$C_BOLD$C_TEXT$title$C_RESET"
    local line="${C_MAUVE}╭$(_rep $((w-2)) '─')╮$C_RESET"
    printf '\n%s\n' "$line"
    printf '%s  %s%s\n' "${C_MAUVE}│$C_RESET" "$t" ""
    if [ -n "$sub" ]; then
        printf '%s  %s%s%s\n' "${C_MAUVE}│$C_RESET" "$C_SUB" "$sub" "$C_RESET"
    fi
    printf '%s\n' "${C_MAUVE}╰$(_rep $((w-2)) '─')╯$C_RESET"
}

phase() { # phase [<n> <total>] <text>   — badge is optional
    local badge="" line; line="$(_rep 56 '─')"
    if [ "$#" -ge 3 ] && [[ "$1" =~ ^[0-9]+$ ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
        badge="${C_MAUVE}[$1/$2]${C_RESET} "
        shift 2
    fi
    printf '\n%s%s%s  %s%s%s%s\n' "$C_SURFACE" "$line" "$C_RESET" "$badge" "$C_BOLD$C_TEXT" "$*" "$C_RESET"
}

# run <cmd…> — dry-run aware plain execution (kept for compatibility)
run() { if [ "${DRY:-0}" -eq 1 ]; then dry "$*"; else "$@"; fi; }

step()  { printf '   %s▸%s %s%s%s\n' "$C_BLUE" "$C_RESET" "$C_TEXT" "$*" "$C_RESET"; }
ok()    { printf '   %s✔%s %s%s%s\n' "$C_GREEN" "$C_RESET" "$C_SUB" "$*" "$C_RESET"; }
warn()  { printf '   %s▲%s %s%s%s\n' "$C_YELLOW" "$C_RESET" "$C_YELLOW" "$*" "$C_RESET"; }
info()  { printf '   %s•%s %s%s%s\n' "$C_TEAL" "$C_RESET" "$C_SUB" "$*" "$C_RESET"; }
dry()   { printf '   %s(dry) %s%s\n' "$C_DIM" "$*" "$C_RESET"; }
kv()    { printf '   %s%-11s%s %s%s%s\n' "$C_LAV" "$1" "$C_RESET" "$C_TEXT" "$2" "$C_RESET"; }
die()   { printf '   %s✘ %s%s\n' "$C_RED" "$*" "$C_RESET" >&2; exit 1; }

# closing box with a summary line
done_box() { # done_box <text>
    local w=54
    printf '\n%s\n' "${C_GREEN}╭$(_rep $((w-2)) '─')╮$C_RESET"
    printf '%s  %s✔ %s%s\n' "${C_GREEN}│$C_RESET" "$C_GREEN$C_BOLD" "$*" "$C_RESET"
    printf '%s\n\n' "${C_GREEN}╰$(_rep $((w-2)) '─')╯$C_RESET"
}

# --- spinner -----------------------------------------------------------------
# spin_run <label> -- <command…>
#   runs the command, showing a spinner; honours $DRY (0/1) when set.
spin_run() {
    local label="$1"; shift
    [ "${1:-}" = "--" ] && shift

    if [ "${DRY:-0}" -eq 1 ]; then dry "$label"; return 0; fi

    if [ -n "$GUM" ]; then
        if "$GUM" spin --spinner dot --spinner.foreground "#cba6f7" \
                      --title "$label" -- "$@"; then
            ok "$label"; return 0
        else
            printf '   %s✘ %s%s\n' "$C_RED" "$label" "$C_RESET" >&2
            return 1
        fi
    fi

    # non-interactive (pipe/log): no animation, just run and report
    if [ ! -t 1 ]; then
        local rc0=0
        "$@" || rc0=$?
        if [ "$rc0" -eq 0 ]; then ok "$label"; else printf '   %s✘ %s%s\n' "$C_RED" "$label" "$C_RESET" >&2; fi
        return "$rc0"
    fi

    # native fallback: run in the background, animate, then report
    local log; log="$(mktemp)"
    "$@" >"$log" 2>&1 &
    local pid=$! i=0 rc=0
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    [ -t 1 ] && printf '\e[?25l'
    while kill -0 "$pid" 2>/dev/null; do
        printf '\r   %s%s%s %s%s%s' "$C_MAUVE" "${frames[i % 10]}" "$C_RESET" "$C_TEXT" "$label" "$C_RESET"
        i=$((i+1)); sleep 0.08
    done
    wait "$pid" || rc=$?
    [ -t 1 ] && printf '\r\e[K\e[?25h' || printf '\r'
    if [ "$rc" -eq 0 ]; then
        ok "$label"
    else
        printf '   %s✘ %s%s\n' "$C_RED" "$label" "$C_RESET" >&2
        [ -s "$log" ] && tail -n 15 "$log" | sed "s/^/     ${C_DIM}│${C_RESET} /"
    fi
    rm -f "$log"
    return "$rc"
}

# spin_capture <label> <outvar> -- <command…>   (keeps stdout, no spinner noise)
spin_capture() {
    local label="$1" __var="$2"; shift 2
    [ "${1:-}" = "--" ] && shift
    local out rc=0
    out="$("$@" 2>/dev/null)" || rc=$?
    [ "$rc" -eq 0 ] && [ -n "$label" ] && ok "$label"
    printf -v "$__var" '%s' "$out"
    return "$rc"
}

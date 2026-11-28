#!/usr/bin/env bash
# =============================================================================
#  arch-kde-rice · installer / bootstrap
#
#  Fresh machine:
#      curl -fsSL https://raw.githubusercontent.com/nizar2004/arch-kde-rice/main/install.sh | bash
#
#  From a clone:
#      ./install.sh
#
#  What it does:
#      1. clones (or updates) the rice into ~/dotfiles
#      2. links the global `backup` and `restore` commands into /usr/local/bin
#      3. runs `restore` to rebuild the whole rice
#
#  Options:
#      --no-restore     only fetch the repo and install the commands
#      --dir <path>     where to put the repo        (default: ~/dotfiles)
#      --repo <url>     override the git remote
#      -h, --help       show this help
# =============================================================================
set -euo pipefail

REPO_URL="${RICE_REPO:-https://github.com/nizar2004/arch-kde-rice.git}"
DEST="${RICE_DIR:-$HOME/dotfiles}"
RUN_RESTORE=1

# ── Catppuccin Mocha TUI (self-contained: this script may be curl-piped) ──────
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-}" != "dumb" ]; then
    C_RESET=$'\e[0m'; C_BOLD=$'\e[1m'; C_DIM=$'\e[2m'
    C_TEXT=$'\e[38;2;205;214;244m'; C_SUB=$'\e[38;2;166;173;200m'
    C_SURFACE=$'\e[38;2;88;91;112m'; C_BLUE=$'\e[38;2;137;180;250m'
    C_MAUVE=$'\e[38;2;203;166;247m'; C_GREEN=$'\e[38;2;166;227;161m'
    C_YELLOW=$'\e[38;2;249;226;175m'; C_RED=$'\e[38;2;243;139;168m'
    C_TEAL=$'\e[38;2;148;226;213m'; C_LAV=$'\e[38;2;180;190;254m'
else
    C_RESET=; C_BOLD=; C_DIM=; C_TEXT=; C_SUB=; C_SURFACE=
    C_BLUE=; C_MAUVE=; C_GREEN=; C_YELLOW=; C_RED=; C_TEAL=; C_LAV=
fi
_rep() { local n="$1" c="$2" s=; for ((i=0;i<n;i++)); do s+="$c"; done; printf '%s' "$s"; }
banner() {
    printf '\n%s\n' "${C_MAUVE}╭$(_rep 54 '─')╮$C_RESET"
    printf '%s  %s%s%s\n' "${C_MAUVE}│$C_RESET" "$C_BOLD$C_TEXT" "$1" "$C_RESET"
    [ -n "${2:-}" ] && printf '%s  %s%s%s\n' "${C_MAUVE}│$C_RESET" "$C_SUB" "$2" "$C_RESET"
    printf '%s\n' "${C_MAUVE}╰$(_rep 54 '─')╯$C_RESET"
}
phase() { printf '\n%s%s%s  %s%s%s%s\n' "$C_SURFACE" "$(_rep 56 '─')" "$C_RESET" "${C_MAUVE}[$1/$2]${C_RESET} " "$C_BOLD$C_TEXT" "$3" "$C_RESET"; }
step()  { printf '   %s▸%s %s%s%s\n' "$C_BLUE" "$C_RESET" "$C_TEXT" "$*" "$C_RESET"; }
ok()    { printf '   %s✔%s %s%s%s\n' "$C_GREEN" "$C_RESET" "$C_SUB" "$*" "$C_RESET"; }
warn()  { printf '   %s▲%s %s%s%s\n' "$C_YELLOW" "$C_RESET" "$C_YELLOW" "$*" "$C_RESET"; }
die()   { printf '   %s✘ %s%s\n' "$C_RED" "$*" "$C_RESET" >&2; exit 1; }
done_box() { printf '\n%s\n%s  %s✔ %s%s\n%s\n\n' \
    "${C_GREEN}╭$(_rep 54 '─')╮$C_RESET" "${C_GREEN}│$C_RESET" "$C_GREEN$C_BOLD" "$*" "$C_RESET" \
    "${C_GREEN}╰$(_rep 54 '─')╯$C_RESET"; }

spin_run() { # spin_run <label> -- <cmd…>
    local label="$1"; shift; [ "${1:-}" = "--" ] && shift
    if command -v gum >/dev/null 2>&1 && [ -t 1 ]; then
        if gum spin --spinner dot --spinner.foreground "#cba6f7" --title "$label" -- "$@"; then ok "$label"; return 0
        else printf '   %s✘ %s%s\n' "$C_RED" "$label" "$C_RESET" >&2; return 1; fi
    fi
    if "$@"; then ok "$label"; else printf '   %s✘ %s%s\n' "$C_RED" "$label" "$C_RESET" >&2; return 1; fi
}

# read from the terminal even when the script is piped (curl | bash)
ask() {
    local reply=""
    if ! read -r -p "$1" reply </dev/tty 2>/dev/null; then
        die "this installer needs an interactive terminal"
    fi
    printf '%s' "$reply"
}

# ── args ──────────────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
    case "$1" in
        --no-restore) RUN_RESTORE=0 ;;
        --dir)        DEST="${2:-}"; shift ;;
        --repo)       REPO_URL="${2:-}"; shift ;;
        -h|--help)    sed -n '2,18p' "${BASH_SOURCE[0]}" 2>/dev/null | sed 's/^# \{0,1\}//' || true; exit 0 ;;
        *)            echo "install.sh: unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done
[ -n "$DEST" ] || die "empty --dir"

banner "arch-kde-rice · installer" "fetch → link commands → rebuild"

# ── [1/3] fetch the repo ──────────────────────────────────────────────────────
phase 1 3 "fetch the repository"
SELF="${BASH_SOURCE[0]:-}"
SELF_DIR=""
if [ -n "$SELF" ] && [ -f "$SELF" ]; then SELF_DIR="$(cd "$(dirname "$SELF")" && pwd)"; fi

if [ -n "$SELF_DIR" ] && [ -d "$SELF_DIR/.git" ] && [ -x "$SELF_DIR/bin/restore" ]; then
    DEST="$SELF_DIR"
    ok "using the local clone at $DEST"
else
    command -v git >/dev/null 2>&1 || die "git is required — install it with:  sudo pacman -S git"
    if [ -d "$DEST/.git" ]; then
        git -C "$DEST" remote set-url origin "$REPO_URL" 2>/dev/null || true
        spin_run "updated $DEST" -- git -C "$DEST" pull --ff-only -q
    elif [ -e "$DEST" ]; then
        die "$DEST exists and is not a git clone — move it away or use --dir"
    else
        spin_run "cloned $REPO_URL" -- git clone -q --depth 1 "$REPO_URL" "$DEST"
    fi
fi
[ -x "$DEST/bin/restore" ] || die "no bin/restore inside $DEST"

# ── [2/3] global commands & options ──────────────────────────────────────────
phase 2 3 "global commands & options"
step "asking for sudo once (to link /usr/local/bin)"
sudo -v || die "sudo was not granted"

# KDE Connect + the phone remote commands: opt-in (restore asks again if you
# run it directly later). Non-interactive installs default to yes.
RUN_KDECONNECT=1
if [ "$RUN_RESTORE" -eq 1 ]; then
    reply=""
    if read -r -p "   Install KDE Connect + phone remote commands? [Y/n] " reply </dev/tty 2>/dev/null; then
        case "$reply" in n|N|no|NO) RUN_KDECONNECT=0 ;; esac
    fi
    if [ "$RUN_KDECONNECT" = 1 ]; then
        ok "KDE Connect + phone remote commands: yes"
    else
        warn "KDE Connect + phone remote commands: no"
    fi
fi
export RICE_KDECONNECT="$RUN_KDECONNECT"

CMDS=(backup restore gsr-replay-watch gsr-replay-ctl rice-wallpaper-rotate rice-netns-setup rice-netns-exec rice-brave-direct)
[ "$RUN_KDECONNECT" = 1 ] && CMDS+=(kdeconnect-sync)
for c in "${CMDS[@]}"; do
    spin_run "/usr/local/bin/$c → $DEST/bin/$c" -- sudo ln -sf "$DEST/bin/$c" "/usr/local/bin/$c"
done

# ── [3/3] restore ─────────────────────────────────────────────────────────────
if [ "$RUN_RESTORE" -eq 1 ]; then
    phase 3 3 "rebuild the rice"
    printf '   %sThis installs packages, sets fish as your shell and restores the Plasma layout.%s\n' "$C_SUB" "$C_RESET"
    case "$(ask "   Continue? [Y/n] ")" in
        n|N|no|NO) warn "skipped restore — run 'restore' when you are ready" ;;
        *)         exec "$DEST/bin/restore" ;;
    esac
else
    phase 3 3 "rebuild the rice"
    warn "skipped (--no-restore) — run 'restore' when you are ready"
fi

done_box "Installer finished"

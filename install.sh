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

# ── pretty output ─────────────────────────────────────────────────────────────
if [ -t 1 ]; then
    B=$'\e[1m'; R=$'\e[0m'; D=$'\e[2m'
    AC=$'\e[38;5;39m'; OK=$'\e[38;5;42m'; WARN=$'\e[38;5;214m'
    ERR=$'\e[38;5;203m'; T=$'\e[38;5;170m'
else
    B=; R=; D=; AC=; OK=; WARN=; ERR=; T=
fi
title() { printf '\n%s◆ %s%s%s\n' "$T" "$B" "$*" "$R"; }
step()  { printf '  %s▸%s %s%s%s\n' "$AC" "$R" "$B" "$*" "$R"; }
ok()    { printf '    %s✔%s %s\n' "$OK" "$R" "$*"; }
warn()  { printf '    %s▲%s %s\n' "$WARN" "$R" "$*"; }
die()   { printf '%s✘ %s%s\n' "$ERR" "$*" "$R" >&2; exit 1; }

# read from the terminal even when the script is piped (curl | bash)
ask() {
    local prompt="$1" reply=""
    if ! read -r -p "$prompt" reply </dev/tty 2>/dev/null; then
        die "this installer needs an interactive terminal (run it in a terminal, not from a file picker)"
    fi
    printf '%s' "$reply"
}

# ── args ──────────────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
    case "$1" in
        --no-restore) RUN_RESTORE=0 ;;
        --dir)        DEST="${2:-}"; shift ;;
        --repo)       REPO_URL="${2:-}"; shift ;;
        -h|--help)    sed -n '2,20p' "${BASH_SOURCE[0]}" 2>/dev/null | sed 's/^# \{0,1\}//' || true; exit 0 ;;
        *)            echo "install.sh: unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done
[ -n "$DEST" ] || die "empty --dir"

# ── 1. fetch the repo ─────────────────────────────────────────────────────────
title "arch-kde-rice · installer"
SELF="${BASH_SOURCE[0]:-}"
SELF_DIR=""
if [ -n "$SELF" ] && [ -f "$SELF" ]; then
    SELF_DIR="$(cd "$(dirname "$SELF")" && pwd)"
fi

if [ -n "$SELF_DIR" ] && [ -d "$SELF_DIR/.git" ] && [ -x "$SELF_DIR/bin/restore" ]; then
    DEST="$SELF_DIR"
    step "using the local clone at $DEST"
    ok "repo found"
else
    if ! command -v git >/dev/null 2>&1; then
        step "git is required to fetch the rice"
        printf '    install it with:  sudo pacman -S git\n'
        die "git is not installed"
    fi
    if [ -d "$DEST/.git" ]; then
        step "updating $DEST"
        git -C "$DEST" remote set-url origin "$REPO_URL" 2>/dev/null || true
        git -C "$DEST" pull --ff-only -q && ok "pulled the latest commit"
    elif [ -e "$DEST" ]; then
        die "$DEST exists and is not a git clone — move it away or use --dir"
    else
        step "cloning $REPO_URL → $DEST"
        git clone -q --depth 1 "$REPO_URL" "$DEST" && ok "cloned"
    fi
fi

[ -x "$DEST/bin/restore" ] || die "no bin/restore inside $DEST"

# ── 2. global commands ────────────────────────────────────────────────────────
title "Installing the global commands"
step "asking for sudo once (to link /usr/local/bin)"
sudo -v || die "sudo was not granted"
for c in backup restore; do
    sudo ln -sf "$DEST/bin/$c" "/usr/local/bin/$c"
    ok "/usr/local/bin/$c → $DEST/bin/$c"
done

# ── 3. restore ────────────────────────────────────────────────────────────────
if [ "$RUN_RESTORE" -eq 1 ]; then
    title "Rebuilding the rice"
    printf '  %sThis installs packages, sets fish as your shell and restores the Plasma\n' "$D"
    printf '  layout. Continue? [Y/n] %s' "$R"
    case "$(ask '')" in
        n|N|no|NO) warn "skipped restore — run 'restore' when you are ready" ;;
        *)         exec "$DEST/bin/restore" ;;
    esac
else
    warn "skipped restore (--no-restore)"
    printf '\n  Run %srestore%s when you are ready.\n' "$B" "$R"
fi

printf '\n%s✨ Done.%s\n' "$OK" "$R"

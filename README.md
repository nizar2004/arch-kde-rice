<div align="center">

# Arch + KDE Plasma Rice

**A vertical-panel KDE Plasma setup for Arch Linux — captured, backed up and restorable with two global commands.**

![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793d1?logo=archlinux&logoColor=white)
![KDE Plasma](https://img.shields.io/badge/KDE-Plasma%206-1d99f3?logo=kde&logoColor=white)
![Shell: fish](https://img.shields.io/badge/shell-fish-4d5a5e?logo=gnu-bash&logoColor=white)

</div>

---

## ⚡ One-command install

On a fresh **Arch + KDE Plasma** install:

```bash
curl -fsSL https://raw.githubusercontent.com/nizar2004/arch-kde-rice/main/install.sh | bash
```

That clones the rice into `~/dotfiles`, links the global `backup` / `restore` commands into
`/usr/local/bin`, then runs `restore` (it asks for your sudo password **once**).

Only want the repo + commands, without rebuilding anything?

```bash
curl -fsSL https://raw.githubusercontent.com/nizar2004/arch-kde-rice/main/install.sh | bash -s -- --no-restore
```

Other flags: `--dir <path>` (where to clone, default `~/dotfiles`), `--repo <url>`.

---

## ✨ What this rice contains

| Area | Details |
| --- | --- |
| 🖥️ **Panels** | Two **vertical** panels — the main taskbar/launcher panel plus a quick-launch icon panel — captured from `plasma-org.kde.plasma.desktop-appletsrc`. |
| 🕰️ **Custom widgets** | `com.cyberbessa.verticalclock` (vertical clock) and `com.nizar.dashboard` (custom start menu). |
| 📏 **Small taskbar icons** | Taskbar icons are forced to **29 px** with the `SmallTaskIcons` Plasma theme (a `widgets/tasks.svgz` margin-hint override) — the panel thickness is never touched. |
| 🐟 **Shell** | **fish** as the real login shell (`usermod -s /usr/bin/fish` + registered in `/etc/shells`), so **every** terminal — Konsole, Alacritty, TTYs, VS Code — starts fish. **oh-my-posh** prompt (`nizar-simple.omp.json`) + custom functions. |
| 🖥️ **Terminal** | **Ghostty** config (Tokyo Night-ish palette, Meslo Nerd Font) **and** a **Konsole** profile with `Command=/usr/bin/fish`. |
| ⚡ **Fetch** | Custom **fastfetch** profile. |
| 🖼️ **Wallpapers** | `~/Pictures/Wallpaper/` wired to Plasma's **Slideshow** engine. |
| 🔋 **Power & lock** | **Never sleeps** (any power source), **screen off after 1 h** of inactivity, **lid close on AC → screen off only**, **no lock screen and no password** — enforced in `powerdevilrc` + `kscreenlockerrc` and applied live during `restore`. |
| 🎛️ **ASUS / ROG** | `restore` installs **rog-control-center**, **asusctl**, **discord** and **power-profiles-daemon** via pacman, then enables the PPD service and restarts `asusd`. |

## 🗂️ Repository layout

```
.
├── bin/
│   ├── lib/tui.sh        # shared Catppuccin TUI (gum-accelerated)
│   ├── backup            # snapshot this machine → repo → push
│   ├── restore           # rebuild the rice on a fresh install
│   ├── kdeconnect-sync   # push the rice's remote commands to paired phones
│   └── kc-display        # switch laptop panel ↔ external monitor (KDE Wayland)
├── config/
│   ├── fish/             # → ~/.config/fish
│   ├── oh-my-posh/       # → ~/.config/oh-my-posh
│   ├── ghostty/          # → ~/.config/ghostty
│   └── fastfetch/        # → ~/.config/fastfetch
├── plasma/
│   ├── config/           # appletsrc, plasmashellrc, plasmarc, kwinrc, kdeglobals, powerdevilrc, kscreenlockerrc, …
│   ├── data/
│   │   ├── plasmoids/    # com.cyberbessa.verticalclock, com.nizar.dashboard
│   │   └── plasma_icons/ # panel launcher icons
│   └── desktoptheme/     # SmallTaskIcons (29 px taskbar icons)
├── systemd/user/         # pairing watcher: auto-add commands to new phones
├── wallpapers/           # → ~/Pictures/Wallpaper
└── fonts/                # user fonts (if any) → ~/.local/share/fonts
```

## 🚀 The three global commands

All install to `/usr/local/bin` (as symlinks into this repo) and can be run from anywhere.

### `backup`
Snapshots the live system into the repo and pushes:

```console
$ backup
◆ Backing up the rice → /home/nizar/dotfiles
  Shell & terminal ✔  Wallpapers ✔  Plasma configuration ✔ …
✨ Backup complete.
```

Options: `backup --no-push` (commit locally only), `backup -m "message"`.

### `restore`
Rebuilds everything on a fresh **Arch + KDE Plasma** install:

```console
$ restore
┳━ Phase 0 · sanity & privileges
┃  ▸ asking for sudo once …
┳━ Phase 1 · dependencies & default shell   # pacman + ASUS/ROG apps + oh-my-posh + chsh fish
┳━ Phase 2 · fonts & terminal configuration # fish, oh-my-posh, ghostty, fastfetch
┳━ Phase 3 · wallpapers                        # → ~/Pictures/Wallpaper/ + org.kde.slideshow
┳━ Phase 4 · Plasma UI, panels & taskbar icons  # widgets, layout, icon size 29
┳━ Phase 5 · power & lock screen             # no sleep, screen off 1 h, lid → screen off, no password
┳━ Phase 6 · KDE Connect                     # remote commands on every paired phone
┳━ Phase 7 · global commands                 # backup / restore / kdeconnect-sync
```

Use `restore --dry-run` to preview every action without changing anything.

### `kdeconnect-sync`
Installs the rice's remote commands on every **paired** KDE Connect device:

| Phone button | Runs |
| --- | --- |
| **Shut down PC** | `systemctl poweroff` |
| **Display: main screen only** | `kc-display main` — laptop panel (eDP*) only |
| **Display: HDMI screen only** | `kc-display external` — HDMI*/DP* monitor only |

It runs automatically on `restore`, and a systemd user **path unit**
(`rice-kdeconnect-sync.path`) watches `~/.config/kdeconnect` — pair a new
phone and the commands appear with no action needed. Devices that already
have their own commands are never touched.

Both `install.sh` and `restore` ask **"Install KDE Connect + phone remote
commands? [Y/n]"** — answer `n` and the package, the phase and the watcher
are all skipped. Changed your mind later? Run `RICE_KDECONNECT=1 restore`.

> The KDE Connect command list is a Qt `QSettings` file: the value must be
> written in Qt's `@ByteArray(…)` encoding or it silently reads back empty —
> this script handles that for you.

## 🖥️ kc-display

```console
$ kc-display status          # what's on right now
HDMI-A-1   ON   connected
eDP-1      off  connected
$ kc-display main            # laptop panel only
$ kc-display external        # external monitor only
```

Outputs are auto-detected at run time (`eDP*` = laptop panel, `HDMI*`/`DP*` =
external), so the same KDE Connect commands work on any machine this rice is
restored to.

## 📦 Manual install

```bash
git clone https://github.com/nizar2004/arch-kde-rice.git ~/dotfiles
sudo ln -sf ~/dotfiles/bin/backup          /usr/local/bin/backup
sudo ln -sf ~/dotfiles/bin/restore         /usr/local/bin/restore
sudo ln -sf ~/dotfiles/bin/kdeconnect-sync /usr/local/bin/kdeconnect-sync
restore
```

## 🖼️ Wallpaper slideshow

The wallpaper library lives in **`wallpapers/`** in this repo. `restore` copies it to
`~/Pictures/Wallpaper/`, finds every desktop containment (`org.kde.plasma.folder`) in
`plasma-org.kde.plasma.desktop-appletsrc`, sets it to **`org.kde.slideshow`** with
`SlidePaths=/home/$USER/Pictures/Wallpaper/` via `kwriteconfig6`, then applies it live with
`org.kde.PlasmaShell.evaluateScript` (`desktops()[i].wallpaperPlugin = 'org.kde.slideshow'`).

To add your own wallpapers later, drop them in `~/Pictures/Wallpaper/` and run `backup`
(see `wallpapers/README.md`).

Verify any time with:

```bash
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
  'var d=desktops(); print(JSON.stringify(d.map(function(x){return x.wallpaperPlugin})))'
```

## 🧩 Why the panel layout replaces (not merges)

plasmashell keeps the whole layout in memory and **writes it back when it exits**. Deploying
`plasma-org.kde.plasma.desktop-appletsrc` while plasmashell is running therefore gets clobbered on
the next restart — the old panel stays and the new applets look merged into it.

`restore` avoids that by doing Phase 4 in this order:

```
stop plasmashell  →  deploy config + widgets + theme + wallpaper containments  →  start plasmashell  →  verify
```

Verification is part of the run:

```console
┃    ✔ panels(): ["right","left"]        # vertical panels applied
┃    ✔ desktop wallpaper plugins: ["org.kde.slideshow","org.kde.slideshow"]
```

## 🐟 Fish everywhere (not just Ghostty)

`restore` Phase 1 does all three steps so fish is the *system* shell:

```bash
grep -qxF "$(command -v fish)" /etc/shells || echo "$(command -v fish)" | sudo tee -a /etc/shells
sudo usermod -s "$(command -v fish)" "$USER"
# plus a Konsole profile with Command=/usr/bin/fish  (config/konsole + config/konsolerc)
```

Log out and back in once for the shell change to reach the current session.

## ⏱️ OS Age (fastfetch)

The fastfetch `OS Age` module reads `~/.local/state/ArchKDE-SystemRestore/os-install-date`
(falling back to the birth time of `/`). `restore` pins it to **2026-07-04** — so the prompt reports
the install age from that date — and makes `/var/log/pacman.log` agree:

1. writes the Unix timestamp for `2026-07-04` to the state file,
2. backs `pacman.log` up to `pacman.log.rice-bak`, prepends
   `[2026-07-04T00:00:00+0000] [PACMAN] Running 'pacman -Syu'` if the log doesn't already start there,
3. `touch -d "2026-07-04 00:00:00" /var/log/pacman.log`.

Change the date by editing `set_os_install_date()` in `bin/restore`. Verify with:

```bash
cat ~/.local/state/ArchKDE-SystemRestore/os-install-date   # → 1783094400
fastfetch | grep 'OS Age'                                  # → : 136 days
```

## 🎨 Terminal UI

`backup`, `restore` and `install.sh` share a Catppuccin Mocha UI (`bin/lib/tui.sh`): rounded
box-drawing banners, `[n/5]` step badges, ✔/✖ status lines and a spinner. It uses
**Charmbracelet `gum`** when installed (`sudo pacman -S gum`) and falls back to pure ANSI/Unicode
otherwise — no hard dependency, and it automatically goes quiet when output is piped.

## 📐 How the 29 px taskbar icons work

Plasma scales taskbar button icons to `panel thickness − theme margin hints`. The `SmallTaskIcons`
theme keeps the stock theme for everything **except** `widgets/tasks.svgz`, where the margin-hint
rectangles are enlarged. `restore` copies that theme, selects it with
`kwriteconfig6 --file plasmarc --group Theme --key name SmallTaskIcons`, and additionally pins
`iconSize=29` on the `icontasks` applet. Nothing is patched in Plasma's binaries and the panel
keeps its original thickness — fully reversible by switching the theme back to `default`.

## 🔒 Notes

- The scripts use `$USER` / `$HOME` throughout; an origin user recorded at backup time
  (`plasma/.origin-user`) is rewritten on restore, so absolute paths in the Plasma config follow
  whoever runs `restore`.
- `restore` installs **only** the lightweight dependencies above — no heavy user apps.
- No secrets are stored in this repo.

## 📄 License

MIT — do whatever you like with it.

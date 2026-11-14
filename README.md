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
| 🖼️ **Wallpapers** | `~/Pictures/Wallpapers/` wired to Plasma's **Slideshow** engine. |

## 🗂️ Repository layout

```
.
├── bin/
│   ├── backup            # snapshot this machine → repo → push
│   └── restore           # rebuild the rice on a fresh install
├── config/
│   ├── fish/             # → ~/.config/fish
│   ├── oh-my-posh/       # → ~/.config/oh-my-posh
│   ├── ghostty/          # → ~/.config/ghostty
│   └── fastfetch/        # → ~/.config/fastfetch
├── plasma/
│   ├── config/           # appletsrc, plasmashellrc, plasmarc, kwinrc, kdeglobals, …
│   ├── data/
│   │   ├── plasmoids/    # com.cyberbessa.verticalclock, com.nizar.dashboard
│   │   └── plasma_icons/ # panel launcher icons
│   └── desktoptheme/     # SmallTaskIcons (29 px taskbar icons)
├── wallpapers/           # → ~/Pictures/Wallpapers
└── fonts/                # user fonts (if any) → ~/.local/share/fonts
```

## 🚀 The two global commands

Both install to `/usr/local/bin` (as symlinks into this repo) and can be run from anywhere.

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
┳━ Phase 1 · dependencies & default shell   # pacman + oh-my-posh + chsh fish
┳━ Phase 2 · fonts & terminal configuration # fish, oh-my-posh, ghostty, fastfetch
┳━ Phase 3 · wallpapers & slideshow         # → ~/Pictures/Wallpapers + org.kde.slideshow
┳━ Phase 4 · Plasma UI, panels & taskbar icons  # widgets, layout, icon size 29
┳━ Phase 5 · global commands
```

Use `restore --dry-run` to preview every action without changing anything.

## 📦 Manual install

```bash
git clone https://github.com/nizar2004/arch-kde-rice.git ~/dotfiles
sudo ln -sf ~/dotfiles/bin/backup  /usr/local/bin/backup
sudo ln -sf ~/dotfiles/bin/restore /usr/local/bin/restore
restore
```

## 🖼️ Wallpaper slideshow

`restore` finds every desktop containment (`org.kde.plasma.folder`) in
`plasma-org.kde.plasma.desktop-appletsrc`, sets it to **`org.kde.slideshow`** with
`SlidePaths=file:///home/$USER/Pictures/Wallpapers` via `kwriteconfig6`, then applies it live with
`org.kde.PlasmaShell.evaluateScript` (`desktops()[i].wallpaperPlugin = 'org.kde.slideshow'`).
Verify any time with:

```bash
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
  'var d=desktops(); print(JSON.stringify(d.map(function(x){return x.wallpaperPlugin})))'
```

## 🐟 Fish everywhere (not just Ghostty)

`restore` Phase 1 does all three steps so fish is the *system* shell:

```bash
grep -qxF "$(command -v fish)" /etc/shells || echo "$(command -v fish)" | sudo tee -a /etc/shells
sudo usermod -s "$(command -v fish)" "$USER"
# plus a Konsole profile with Command=/usr/bin/fish  (config/konsole + config/konsolerc)
```

Log out and back in once for the shell change to reach the current session.

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

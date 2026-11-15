# Wallpapers

This folder is the wallpaper library for the rice.

- **On restore** it is copied to `~/Pictures/Wallpapers/` and Plasma's desktop is pointed at that
  folder with the **Slideshow** wallpaper plugin (`org.kde.slideshow`).
- **On backup** `~/Pictures/Wallpapers/` is mirrored back into this folder, so whatever you add
  there is kept in the repo. (This file is protected from the mirror's `--delete`, so it stays.)

## Adding your own

```bash
# 1. drop the images in
cp ~/Downloads/my-wallpaper.jpg ~/Pictures/Wallpapers/

# 2. save them to the repo
backup
```

Any of `.jpg .jpeg .png .webp` works. The slideshow rotates through everything in
`~/Pictures/Wallpapers/` (interval: 30 min by default).

> Restore only copies images — it never deletes anything already in `~/Pictures/Wallpapers/`,
> so your personal wallpapers survive a re-run.

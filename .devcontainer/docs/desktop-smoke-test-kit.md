# Desktop smoke-test kit for draft PR branches

Use this kit to build repo-local Arch packages for draft desktop branches and manually validate them on an Arch desktop. The helper creates ignored worktrees and artifacts under `artifacts/`; it does not install host packages, run host `pacman`, merge branches, or prune/remove anything outside the repository.

## Prerequisites

The branch-build helper does not install host packages. Before running it, make sure these tools are available on the host:

- `git`
- `cargo` / Rust stable
- Docker or Podman for the Arch `makepkg` container
- one frontend package tool: `corepack`, standalone `pnpm`, or VitePlus `vp`

If you use VitePlus and your shell does not already expose it, either source it first:

```bash
source "${VITE_PLUS_ENV:-$HOME/.vite-plus/env}"
```

or let the helper source `$HOME/.vite-plus/env` automatically when it is present.

## Build branch packages

Fetch the draft branch refs first:

```bash
git fetch origin
```

Build the PR #8 Wayland tray package:

```bash
.devcontainer/scripts/build-branch-arch-package.sh roadmap/wayland-tray-options
```

Build the PR #7 MPRIS2/KDE Connect package:

```bash
.devcontainer/scripts/build-branch-arch-package.sh roadmap/mpris2-now-playing
```

The wrapper creates these repo-local worktrees:

```text
artifacts/branch-arch-package/worktrees/roadmap__wayland-tray-options/
artifacts/branch-arch-package/worktrees/roadmap__mpris2-now-playing/
```

Inside each worktree it runs:

```bash
# frontend tool can be corepack pnpm, pnpm, or VitePlus vp
<pnpm-tool> install --frozen-lockfile
<pnpm-tool> --filter @nuclearplayer/player build:frontend
cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml
# export copies target/release/player (plain cargo) or target/release/nuclear-music-player (Tauri-renamed) to nuclear-music-player-arch
.devcontainer/scripts/export-linux-binary.sh
.devcontainer/scripts/build-arch-package.sh
.devcontainer/scripts/validate-arch-package.sh
```

Package outputs stay inside the corresponding branch worktree:

```text
artifacts/branch-arch-package/worktrees/<branch-slug>/artifacts/arch-package/packages/*.pkg.tar.zst
```

The package validation checks that each package contains `/usr/bin/nuclear-music-player-arch`, contains the desktop file, and uses `Exec=nuclear-music-player-arch %u`.

If a build fails after creating a generated worktree, retry without deleting evidence:

```bash
.devcontainer/scripts/build-branch-arch-package.sh --reuse-existing roadmap/wayland-tray-options
```

Or remove only the generated repo-local worktree and start clean:

```bash
git worktree remove "$PWD/artifacts/branch-arch-package/worktrees/roadmap__wayland-tray-options"
.devcontainer/scripts/build-branch-arch-package.sh roadmap/wayland-tray-options
```

If you mistype a branch name, the helper lists matching local/origin branches where possible.

To rerun validation from the smoke-kit branch after a package build:

```bash
WAYLAND_PACKAGE_DIR="$PWD/artifacts/branch-arch-package/worktrees/roadmap__wayland-tray-options/artifacts/arch-package/packages"
MPRIS_PACKAGE_DIR="$PWD/artifacts/branch-arch-package/worktrees/roadmap__mpris2-now-playing/artifacts/arch-package/packages"
.devcontainer/scripts/validate-arch-package.sh "$WAYLAND_PACKAGE_DIR"
.devcontainer/scripts/validate-arch-package.sh "$MPRIS_PACKAGE_DIR"
```

## Install a generated package

Install only one draft package at a time so behavior is attributable to that branch.

PR #8 Wayland tray package:

```bash
WAYLAND_PACKAGE_DIR="$PWD/artifacts/branch-arch-package/worktrees/roadmap__wayland-tray-options/artifacts/arch-package/packages"
WAYLAND_PACKAGE="$(find "$WAYLAND_PACKAGE_DIR" -maxdepth 1 -type f -name '*.pkg.tar.zst' -print -quit)"
test -n "$WAYLAND_PACKAGE"
sudo pacman -U --needed "$WAYLAND_PACKAGE"
command -v nuclear-music-player-arch
/usr/bin/nuclear-music-player-arch --version || true
```

PR #7 MPRIS2/KDE Connect package:

```bash
MPRIS_PACKAGE_DIR="$PWD/artifacts/branch-arch-package/worktrees/roadmap__mpris2-now-playing/artifacts/arch-package/packages"
MPRIS_PACKAGE="$(find "$MPRIS_PACKAGE_DIR" -maxdepth 1 -type f -name '*.pkg.tar.zst' -print -quit)"
test -n "$MPRIS_PACKAGE"
sudo pacman -U --needed "$MPRIS_PACKAGE"
command -v nuclear-music-player-arch
/usr/bin/nuclear-music-player-arch --version || true
```

## Evidence directory

Keep smoke evidence repo-local:

```bash
mkdir -p artifacts/desktop-smoke-evidence/wayland-tray
mkdir -p artifacts/desktop-smoke-evidence/mpris-kdeconnect
```

Record the session context before testing:

```bash
{
  date -Is
  echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-unset}"
  echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-unset}"
  pacman -Q arch-nuclear-bin || true
  command -v nuclear-music-player-arch || true
} | tee artifacts/desktop-smoke-evidence/session-context.txt
```

Launch from a terminal so app logs are captured:

```bash
/usr/bin/nuclear-music-player-arch 2>&1 | tee artifacts/desktop-smoke-evidence/app.log
```

## PR #8 Wayland tray smoke plan

Run this plan on a Wayland session, preferably KDE Plasma or another desktop with a visible status notifier tray.

1. Install the `roadmap/wayland-tray-options` package.
2. Start `/usr/bin/nuclear-music-player-arch` from a terminal and save logs under `artifacts/desktop-smoke-evidence/wayland-tray/`.
3. Confirm the tray icon appears, is recognizable, is not blank, and matches the installed Nuclear icon.
4. Close the main window with the titlebar close button. Expected: the app stays running, the tray icon remains visible, and no crash appears in the terminal log.
5. Restore/show the app from the tray menu or tray icon. Expected: the main window returns and remains usable.
6. Minimize the window. Expected: the app minimizes without losing the tray icon.
7. Restore the minimized window from the taskbar or tray. Expected: the app returns to the foreground.
8. Use the tray quit action. Expected: the process exits, the tray icon disappears, and no stale `nuclear-music-player-arch` process remains.
9. Relaunch once after quit. Expected: the tray icon and window restore behavior still work.

Suggested evidence commands:

```bash
pgrep -af nuclear-music-player-arch | tee artifacts/desktop-smoke-evidence/wayland-tray/process-before-quit.txt
ls -l /usr/share/icons/hicolor/512x512/apps/*nuclear* | tee artifacts/desktop-smoke-evidence/wayland-tray/installed-icons.txt
pgrep -af nuclear-music-player-arch | tee artifacts/desktop-smoke-evidence/wayland-tray/process-after-quit.txt || true
```

Also save screenshots or screen recordings showing the tray icon, close-to-tray state, restore state, minimized state, and quit result.

## PR #7 MPRIS2/KDE Connect smoke plan

Run this plan after installing the `roadmap/mpris2-now-playing` package. Have a playable track ready and KDE Connect paired if KDE Connect behavior is in scope for the machine.

1. Start `/usr/bin/nuclear-music-player-arch` from a terminal and save logs under `artifacts/desktop-smoke-evidence/mpris-kdeconnect/`.
2. Play a track with known title, artist, and artwork.
3. Find the MPRIS player name and capture metadata:

```bash
PLAYER="$(playerctl -l | grep -i 'nuclear' | head -n1)"
test -n "$PLAYER"
playerctl -p "$PLAYER" status | tee artifacts/desktop-smoke-evidence/mpris-kdeconnect/status.txt
playerctl -p "$PLAYER" metadata xesam:title | tee artifacts/desktop-smoke-evidence/mpris-kdeconnect/title.txt
playerctl -p "$PLAYER" metadata xesam:artist | tee artifacts/desktop-smoke-evidence/mpris-kdeconnect/artist.txt
playerctl -p "$PLAYER" metadata mpris:artUrl | tee artifacts/desktop-smoke-evidence/mpris-kdeconnect/artwork.txt
```

4. Confirm the reported title, artist, artwork URL/path, and playback status match the current track.
5. Exercise controls through MPRIS:

```bash
playerctl -p "$PLAYER" pause
playerctl -p "$PLAYER" status | tee -a artifacts/desktop-smoke-evidence/mpris-kdeconnect/control-status.txt
playerctl -p "$PLAYER" play
playerctl -p "$PLAYER" status | tee -a artifacts/desktop-smoke-evidence/mpris-kdeconnect/control-status.txt
playerctl -p "$PLAYER" next
playerctl -p "$PLAYER" metadata xesam:title | tee -a artifacts/desktop-smoke-evidence/mpris-kdeconnect/control-title.txt
```

6. In KDE Connect, confirm the phone/remote device shows the same track title, artist, artwork, and playing/paused status.
7. Use KDE Connect controls for play/pause and next/previous. Expected: Nuclear responds and `playerctl` status/metadata update accordingly.
8. Stop playback or quit the app. Expected: MPRIS status changes appropriately or the Nuclear MPRIS player disappears from `playerctl -l` without a stale KDE Connect now-playing entry.

Optional D-Bus signal evidence:

```bash
dbus-monitor --session "type='signal',interface='org.freedesktop.DBus.Properties'" \
  > artifacts/desktop-smoke-evidence/mpris-kdeconnect/dbus-properties.log
```

Stop `dbus-monitor` after changing tracks and controls, then inspect the log for Nuclear/MPRIS property changes.

## Rollback

Remove the installed draft package:

```bash
sudo pacman -Rns arch-nuclear-bin
command -v nuclear-music-player-arch || true
```

If you need to remove a repo-local smoke worktree after collecting evidence, remove only the ignored worktree path that the wrapper printed:

```bash
git worktree remove "$PWD/artifacts/branch-arch-package/worktrees/roadmap__wayland-tray-options"
git worktree remove "$PWD/artifacts/branch-arch-package/worktrees/roadmap__mpris2-now-playing"
```

Do not run Docker/Podman prune commands or delete paths outside this repository as part of the smoke workflow.

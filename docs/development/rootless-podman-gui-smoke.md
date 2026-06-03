# Rootless Podman GUI smoke workflow

This workflow is for Arch/Wayland-focused branch smoke testing without installing Tauri GUI dependencies on the host. It uses rootless Podman, mounts the current checkout/worktree, and forwards the host GUI/session sockets needed by a Tauri app.

## Quick start

From any checkout or worktree of `blockedby/arch-nuclear`:

```bash
# Build the reusable Arch GUI dev image. This uses Podman only, not Docker.
tools/podman-gui/podman-gui-smoke build-image

# Open a shell in the PR #8 branch checkout inside the container.
tools/podman-gui/podman-gui-smoke shell --branch roadmap/wayland-tray-options

# Run the player dev app for the PR #8 branch inside the container.
tools/podman-gui/podman-gui-smoke dev --branch roadmap/wayland-tray-options

# Run the MPRIS branch the same way.
tools/podman-gui/podman-gui-smoke dev --branch roadmap/mpris2-now-playing
```

For an existing local worktree or any other branch:

```bash
# Use the current checkout/worktree and do not change branches.
tools/podman-gui/podman-gui-smoke shell

# Mount a different worktree path.
tools/podman-gui/podman-gui-smoke shell --repo /path/to/arch-nuclear-worktree

# Run any command in the mounted checkout.
tools/podman-gui/podman-gui-smoke run -- pnpm --filter @nuclearplayer/player test
```

The mounted checkout is the real host worktree, so `git checkout`, generated files, `node_modules`, Cargo `target`, and other caches created by container commands appear in that worktree. The wrapper also creates an ephemeral writable host runtime HOME for each container run and mounts it at `/tmp/arch-nuclear-home`, so Corepack, pnpm, and Cargo can write HOME-scoped caches without changing your real host HOME.

## What the image contains

`tools/podman-gui/Containerfile` is Arch-based and installs the dependencies commonly needed for Nuclear/Tauri GUI smoke work:

- Node.js, npm/Corepack/pnpm, Rust stable, base build tools, `pkgconf`, OpenSSL
- GTK/WebKit (`gtk3`, `webkit2gtk-4.1`, `libsoup3`, desktop/icon tools)
- tray/status notifier libraries (`libappindicator-gtk3`, `libayatana-appindicator`)
- GStreamer plugin families used by media playback
- DBus, PipeWire/Pulse, playerctl, Mesa, X11/Wayland-adjacent runtime tools

## Runtime wiring

The wrapper runs rootless `podman run --userns keep-id` and mounts/forwards what is available from the host session:

- current repository/worktree at `/workspace/arch-nuclear`
- ephemeral host-created runtime HOME mounted writable at `/tmp/arch-nuclear-home` for Corepack/pnpm/Cargo cache paths
- `XDG_RUNTIME_DIR` and the Wayland socket named by `WAYLAND_DISPLAY`
- session DBus socket from `DBUS_SESSION_BUS_ADDRESS` when it is a local `unix:path=` socket
- Pulse/PipeWire environment variables and runtime directory sockets
- `/dev/dri` when present for GPU acceleration
- X11 fallback variables (`DISPLAY`, `XAUTHORITY`) when present
- desktop/session identity variables (`XDG_CURRENT_DESKTOP`, `XDG_SESSION_DESKTOP`, `DESKTOP_SESSION`, `KDE_SESSION_VERSION`, `QT_QPA_PLATFORMTHEME`, `GTK_THEME`, `ICON_THEME`)
- read-only host user theme/icon/font config when present, mounted under the container HOME: GTK 3/4 config, `kdeglobals`, Kvantum config, user icons, user fonts, `.icons`, and `.themes`

The workflow intentionally does not mount `/var/run/docker.sock`, does not require Docker, and does not run `sudo` or host package-manager commands.

## Smoke-test notes

Suggested PR #8 Wayland tray smoke sequence:

```bash
tools/podman-gui/podman-gui-smoke dev --branch roadmap/wayland-tray-options
```

Then, in the app:

1. Enable the close-to-tray and minimize-to-tray settings added by the branch.
2. Press the window minimize button and observe whether the window is hidden from the compositor task/open-app list or only minimized.
3. Press the close X and observe whether the close request is intercepted and the window hides, closes, or does nothing.
4. Use the tray menu, if visible, to show the app and quit.

Suggested MPRIS branch smoke command:

```bash
tools/podman-gui/podman-gui-smoke dev --branch roadmap/mpris2-now-playing
```

Then observe DBus/MPRIS behavior from another terminal on the host or inside the container using `playerctl` as appropriate for the session.

## Limitations and security model

- Rootless Podman reduces host privilege, but this is not a sandbox for untrusted code. The container can access the mounted checkout and GUI/session sockets you expose.
- Wayland, session DBus, PipeWire/Pulse, and `/dev/dri` access are intentionally exposed so the Tauri app can behave like a desktop app. Treat the container as part of the logged-in desktop session while it is running.
- The workflow forwards common desktop theme hints and read-only user theme/icon/font files, but it does not install missing host themes inside the image. If the container lacks the selected engine or theme package, GTK/WebKit may still fall back to a different appearance.
- The runtime HOME is a temporary host directory created by the wrapper for each `shell`, `dev`, `check`, or `run` invocation and removed after the container exits. Put persistent project state in the mounted checkout, not in `/tmp/arch-nuclear-home`.
- The workflow does not guarantee compositor-specific tray behavior. KDE, GNOME, Sway, and other status-notifier hosts may differ and still need manual observation.
- SELinux labels are disabled for this GUI run mode (`--security-opt label=disable`) because GUI socket mounts commonly fail otherwise. The checkout mount deliberately omits Podman `:Z`/`:z` relabel options, so this workflow does not relabel the host checkout by default. On systems that require strict labels, adapt the mount policy locally.
- The image build and app dependency install use network access. The static verification for this branch does not build the image or run the GUI.
- Full production packaging (`pnpm build`, `tauri build`, AppImage/deb/rpm bundles, signing, release jobs) is intentionally outside this workflow's quick smoke path.

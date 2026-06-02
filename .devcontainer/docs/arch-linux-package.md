# Arch Linux pacman package

This repo-local workflow builds the fork-specific Arch `arch-nuclear-bin` `pkg.tar.zst` package from the plain Arch Nuclear release binary. It does not use or require an AppImage, Debian package, RPM package, host `pacman`, or host `makepkg`.

## Prerequisites

- Docker or Podman available on the host.
- A plain Linux release executable exported to `artifacts/linux-arch-bin/nuclear-music-player-arch`.
- No host dependency installation is performed by the helper.

Build and export the plain executable first:

```bash
corepack pnpm --filter @nuclearplayer/player build:frontend
cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml
.devcontainer/scripts/export-linux-binary.sh
```

## Build the package

```bash
.devcontainer/scripts/build-arch-package.sh
```

The helper stages the binary, desktop file, icon, license, and `PKGBUILD` under:

```text
artifacts/arch-package/staging/<timestamp>/
```

It runs `makepkg -d` as a non-root user inside an `archlinux:base-devel` container. The package metadata still declares runtime dependencies; the helper does not install those runtime packages in the build container because the package is assembled from an already-built binary. Packages are written to:

```text
artifacts/arch-package/packages/
```

Other makepkg work files and logs stay under:

```text
artifacts/arch-package/build/<timestamp>/
artifacts/arch-package/sources/<timestamp>/
artifacts/arch-package/logs/<timestamp>/
```

## Runtime dependencies

The `PKGBUILD` declares the runtime dependencies expected for the Tauri GTK/WebKit binary on Arch:

- `webkit2gtk-4.1`
- `gtk3`
- `hicolor-icon-theme`
- `gst-plugins-base`
- `gst-plugins-good`

Optional media codec packages are declared as `optdepends`: `gst-plugins-bad`, `gst-plugins-ugly`, and `gst-libav`.

## Package contents

The `arch-nuclear-bin` package installs:

```text
/usr/bin/nuclear-music-player-arch
/usr/share/applications/com.nuclearplayer.desktop
/usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.png
/usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.Nuclear.png
/usr/share/icons/hicolor/512x512/apps/nuclear-music-player.png
/usr/share/icons/hicolor/512x512/apps/nuclear-music-player-arch.png
/usr/share/licenses/arch-nuclear-bin/LICENSE
```

The desktop file comes from `packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop` and is installed as `com.nuclearplayer.desktop` for the Arch package. During packaging, its `Exec`, `Icon`, and `StartupWMClass` fields are patched to `nuclear-music-player-arch %u` and `com.nuclearplayer`, matching the Tauri GTK app id enabled by `packages/player/src-tauri/tauri.conf.json`. The icon comes from `packages/player/src-tauri/icons/icon.png` and is installed under the Tauri identifier, existing Flatpak-style application id, and binary lookup names.

## Configuration

Optional environment overrides:

```bash
CONTAINER_RUNTIME=podman .devcontainer/scripts/build-arch-package.sh
ARCH_PACKAGE_CONTAINER_IMAGE=archlinux:base-devel .devcontainer/scripts/build-arch-package.sh
ARCH_PACKAGE_BINARY=/path/inside/repo/to/nuclear-music-player-arch .devcontainer/scripts/build-arch-package.sh
ARCH_PACKAGE_ARTIFACT_DIR=/path/inside/repo/to/artifacts/arch-package .devcontainer/scripts/build-arch-package.sh
```

`ARCH_PACKAGE_BINARY` and `ARCH_PACKAGE_ARTIFACT_DIR` must stay inside the repository. The default artifact paths already satisfy this.

## Safety assumptions

- The helper does not install packages on the host.
- The helper does not run `docker prune`, `podman system prune`, volume prune, or destructive cleanup.
- Host-visible writes are limited to repo-local artifact directories under `artifacts/arch-package/`.
- If the exported binary is missing, the helper fails before starting the container and prints the build/export commands above.

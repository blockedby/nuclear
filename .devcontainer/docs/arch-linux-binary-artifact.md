# Arch Linux plain binary artifact

The preferred repo-local workflow for an Arch-friendly Nuclear artifact is a plain Linux executable copied from Tauri's release build output, not an AppImage.

Tauri creates the executable at:

```text
packages/player/src-tauri/target/release/nuclear-music-player
```

Copy it into a repo-local artifact directory with:

```bash
.devcontainer/scripts/export-linux-binary.sh
```

By default, the script writes:

```text
artifacts/linux-arch-bin/nuclear-music-player
```

To regenerate the binary without requiring AppImage bundling or updater signing, build the frontend and Rust release binary directly:

```bash
source /home/kcnc/.vite-plus/env
corepack pnpm --filter @nuclearplayer/player build:frontend
cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml
.devcontainer/scripts/export-linux-binary.sh
```

This produces a dynamically linked Linux ELF executable suitable for use on Arch Linux systems that provide the required runtime libraries. It is not a pacman package.

The current Tauri config bundles Linux targets as AppImage, deb, and rpm when `tauri build` runs with `bundle.targets = "all"`. Tauri does not directly produce Arch `pkg.tar.zst`/pacman packages from this configuration. If a pacman package is required, create a separate Arch `PKGBUILD` around this binary and desktop/icon assets, or use a separate packaging tool. Do not require AppImage as the deliverable for the plain-binary workflow.

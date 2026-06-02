# Arch PKGBUILD support plan

## Intake
Goal: add real Arch Linux pacman package support for this fork by packaging the existing plain release binary with desktop and icon assets; avoid AppImage dependency.
In scope: repo-local packaging files, PKGBUILD, safe container-based makepkg helper, docs, syntax/build verification, commit and push only to origin blockedby/nuclear.
Out of scope: upstream nukeop PRs, host dependency installs, destructive cleanup, global Docker prune, AppImage package path.
Done state: branch contains committed Arch packaging workflow and documentation; syntax verified; package build attempted/built in safe container when feasible; final report written to /home/kcnc/code/tools/nuclear-arch-pkgbuild-report.md.
Blocking unknowns: whether Docker/container runtime and any prebuilt binary artifact are available locally.

## Repo orientation
- Tauri metadata: packages/player/src-tauri/tauri.conf.json productName Nuclear, mainBinaryName nuclear-music-player, version 1.39.0, identifier com.nuclearplayer.
- Desktop asset: packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop uses Exec=nuclear-music-player %u and Icon=com.nuclearplayer.Nuclear.
- Icon asset: packages/player/src-tauri/icons/icon.png (plus icns/ico).
- Existing binary export: .devcontainer/scripts/export-linux-binary.sh copies packages/player/src-tauri/target/release/nuclear-music-player to artifacts/linux-arch-bin/nuclear-music-player.
- Existing docs: .devcontainer/docs/arch-linux-binary-artifact.md explains plain binary workflow and need for separate PKGBUILD.

## Reuse discovery
- Reuse binary export path and binary name from export-linux-binary.sh.
- Reuse Tauri desktop file and icon assets directly instead of duplicating where possible.
- Reuse player package / tauri version 1.39.0 for pkgver.

## Missing pieces
- PKGBUILD for a binary package that installs /usr/bin/nuclear-music-player, desktop file, icon, and license/docs as appropriate.
- Optional local source staging or relative path handling so makepkg can consume repo-local binary/assets.
- Safe helper script using an Arch container, non-root makepkg user, repo-local output dir, no host pacman installs.
- Documentation for assumptions, runtime dependencies, and rebuild commands.

## Task 1: Arch package workflow
Goal:
- Add repo-local Arch packaging workflow around the plain release binary and Tauri desktop/icon assets.
Boundary:
- System area: packaging/devcontainer scripts/docs.
- Primary verification: shell syntax checks, makepkg source/package validation, optional container package build.
Existing pattern / reuse:
- .devcontainer/scripts/export-linux-binary.sh
- .devcontainer/docs/arch-linux-binary-artifact.md
- packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop
- packages/player/src-tauri/icons/icon.png
Missing change:
- Add PKGBUILD, safe helper script, and documentation.
Scope / likely files:
- .devcontainer/arch-package/PKGBUILD
- .devcontainer/scripts/build-arch-package.sh
- .devcontainer/docs/arch-linux-package.md
Acceptance criteria:
- PKGBUILD packages the plain binary, desktop file, and icon assets without AppImage.
- Helper script builds inside an Arch container as non-root and writes only repo-local artifacts.
- Docs state prerequisites, assumptions, runtime deps, exact build commands, and artifact locations.
- No upstream PR; push only origin.
Test plan:
- Positive: bash -n helper/export scripts; parse package metadata from Tauri/package json; run makepkg --printsrcinfo or makepkg build in Arch container if Docker available and binary exists/can be built.
- Negative: helper fails clearly when binary artifact is missing and does not install host packages.
- Manual: inspect package contents with tar if package builds.
Dependencies:
- Depends on: none.
- Blocks: final verification/report.
Executor:
- aad-implementer.

## Dependency graph
- Task 1 runs as a single implementer task; final owner verification follows.

## Execution ledger
- 2026-06-02: Owner created worktree/branch arch-pkgbuild-support and task package.
- 2026-06-02: Implementer added `.devcontainer/arch-package/PKGBUILD`, `.devcontainer/scripts/build-arch-package.sh`, Arch package docs, and verification artifact. Syntax and missing-binary checks passed. Containerized `makepkg` was verified with an ignored synthetic executable because no real exported release binary was present; package contents and `.PKGINFO` were inspected.

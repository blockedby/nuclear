# Arch tray/logo metadata fix plan

## Intake
Goal: fix Arch package/runtime metadata so installed Nuclear uses the real logo in desktop/taskbar/tray where possible, avoiding generic Wayland icon.
Scope: packaging, desktop file, icon install paths/names, Tauri app/window metadata only if necessary.
Out of scope: upstream PR, broad app source changes, host dependency installs, destructive cleanup outside repo.
Done: committed and pushed to origin master; package rebuilt with contents/metadata verified; user gets reinstall/cache refresh commands and Wayland limitations.
Blocking unknowns: exact desktop shell behavior can vary; verify metadata/package contents locally.

## Repo orientation
Likely areas: aur/PKGBUILD, repo-local Arch build scripts, packages/player/src-tauri/tauri.conf.json, icon assets under packages/player/src-tauri/icons, generated desktop metadata.
Verification: repo-local Arch package build script; inspect built package with tar/bsdtar/pacman tools available in environment/container.

## Reuse discovery
Follow existing Arch packaging support on current master. Reuse Tauri bundle identifiers/icon assets rather than adding new logo artwork.

## Missing pieces
Need align desktop Icon name, StartupWMClass/window class/app id, and installed hicolor icon names. Add justified fallback aliases/symlinks if package currently installs only one lookup name.

## Plan tasks
### Task 1: Arch metadata/icon alignment
Goal: installed package provides desktop metadata and icon lookup names matching Tauri runtime identity, including common Wayland desktop environments.
Boundary: Arch package/runtime metadata.
Primary verification: rebuild Arch package and inspect package contents plus relevant metadata fields.
Existing pattern / reuse: existing aur/PKGBUILD, Tauri config/icon assets.
Missing change: patch package metadata/install steps as needed.
Scope / likely files: aur/*, packaging scripts, packages/player/src-tauri/tauri.conf.json if needed.
Acceptance criteria:
- .desktop file Icon resolves to an installed hicolor icon name in package.
- StartupWMClass (or runtime class equivalent) matches app/window identifier used by Tauri where possible.
- package includes real Nuclear logo icons for common lookup names justified by runtime/desktop metadata.
- Changes stay scoped to packaging/metadata.
Test plan:
- Build package with repo-local script/container as available.
- Inspect generated package file list and desktop metadata.
- Optional: inspect screenshot only for symptom confirmation.
Dependencies: none.
Executor: aad-implementer.
Status: pending.
Report path: docs/plans/2026-06-02-tray-logo-fix/reports/aad-implementer-arch-logo.md

## Execution ledger
- Task 1 status: done by aad-implementer.
- Implementation commits: 9f760697 Fix Arch package app icon metadata; e5c55728 Add Arch logo metadata verification report.
- Owner fresh verification: package archive exists at `/home/kcnc/code/apps/nuclear/.worktrees/tray-logo-fix/artifacts/arch-package-test/out/packages/nuclear-player-bin-1.39.0-1-x86_64.pkg.tar.zst`; `tar -tf` shows `usr/share/applications/com.nuclearplayer.desktop` and the three hicolor icon names; desktop metadata has `Icon=com.nuclearplayer` and `StartupWMClass=com.nuclearplayer`; `git diff --check` and Tauri JSON/app id check passed.

## Final done-state
Status: ready with limitation that the verified package archive uses a synthetic executable, so distribution should rebuild the Arch package with the real release binary. The metadata/package assembly fix is complete and scoped to Arch packaging/runtime app id metadata.
Issues:
- R-01: Generic Wayland icon risk from mismatched desktop/runtime/icon identity resolved by installing Arch desktop entry as `com.nuclearplayer.desktop`, patching `Icon` and `StartupWMClass` to `com.nuclearplayer`, enabling Tauri GTK app id, and installing real logo hicolor aliases.
- F/U: none requiring GitHub issue inside this scoped task.

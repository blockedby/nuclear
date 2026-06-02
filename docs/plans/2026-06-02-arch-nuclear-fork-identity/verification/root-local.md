# Root verification: Arch Nuclear fork identity

## Repository and GitHub operations

- PASS repo URL: `gh repo view blockedby/arch-nuclear --json nameWithOwner,url,viewerPermission,hasIssuesEnabled,defaultBranchRef`
  - `nameWithOwner=blockedby/arch-nuclear`
  - `url=https://github.com/blockedby/arch-nuclear`
  - `viewerPermission=ADMIN`
  - `hasIssuesEnabled=true`
  - `defaultBranchRef.name=master`
- PASS local remotes:
  - `origin` fetch/push: `https://github.com/blockedby/arch-nuclear.git`
  - `upstream` fetch: `https://github.com/nukeop/nuclear.git`
  - `upstream` push: `DISABLED`
- PASS branch push: `git ls-remote origin refs/heads/master refs/heads/arch-nuclear-identity`
  - Both refs point to `23fcffa9962e25aea777984fef6d4d4f6affd0ba` before this root evidence commit.

## Issues created

- PASS https://github.com/blockedby/arch-nuclear/issues/1 — Wayland tray and close/minimize-to-tray support
- PASS https://github.com/blockedby/arch-nuclear/issues/2 — MPRIS2 and KDE Connect now-playing metadata support
- PASS https://github.com/blockedby/arch-nuclear/issues/3 — GitHub Actions release workflow for Arch pkg.tar.zst artifacts
- PASS https://github.com/blockedby/arch-nuclear/issues/4 — Package and app identity cleanup follow-up

## Local package verification

Commands run from repo root:

```bash
bash -n .devcontainer/scripts/build-arch-package.sh
bash -n .devcontainer/scripts/export-linux-binary.sh
.devcontainer/scripts/export-linux-binary.sh
.devcontainer/scripts/build-arch-package.sh
```

Result: PASS.

Evidence:

- Exported binary: `artifacts/linux-arch-bin/nuclear-music-player-arch`
  - ELF x86-64 executable, size 52M.
- Arch package artifact: `artifacts/arch-package/packages/arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst`
  - size 18M.

Package contents inspection:

```bash
tar -tf artifacts/arch-package/packages/arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst \
  | grep -E '(^usr/bin/nuclear-music-player-arch$|^usr/share/applications/com.nuclearplayer.desktop$|^usr/share/licenses/arch-nuclear-bin/LICENSE$)'
tar -xOf artifacts/arch-package/packages/arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst \
  usr/share/applications/com.nuclearplayer.desktop \
  | grep -E '^(Exec|Icon|StartupWMClass)='
```

Result: PASS.

Matched output:

```text
usr/bin/nuclear-music-player-arch
usr/share/applications/com.nuclearplayer.desktop
usr/share/licenses/arch-nuclear-bin/LICENSE
Exec=nuclear-music-player-arch %u
Icon=com.nuclearplayer
StartupWMClass=com.nuclearplayer
```

## Root acceptance matrix

- Rename repo and local origin: PASS.
- Create GitHub roadmap issues: PASS.
- README fork notice and differences: PASS by committed README inspection and slice report.
- Arch package binary rename and desktop Exec: PASS by PKGBUILD inspection and package contents verification.
- Scripts/docs rebuild renamed package: PASS by committed docs/scripts and root package build.
- Minimal GitHub Actions release workflow: PASS by committed `.github/workflows/release-arch-package.yml`; not executed remotely because no tag/manual run was triggered in this task.
- Commit and push changes to renamed repo: PASS; master and branch pushed to origin.
- No upstream PR/push: PASS; no upstream PR opened, upstream push URL disabled locally.

# Arch package verification

## Scope

Verified repo-local Arch packaging workflow for the plain `nuclear-music-player` binary, desktop file, icon, helper safety checks, and documentation. No host packages were installed.

## Commands and evidence

### File presence red/green

```bash
set -e
for required in .devcontainer/arch-package/PKGBUILD .devcontainer/scripts/build-arch-package.sh .devcontainer/docs/arch-linux-package.md; do
  test -f "$required"
done
```

- Before implementation: failed with exit code 1 because files were absent.
- After implementation: passed.

### Script syntax

```bash
bash -n .devcontainer/scripts/export-linux-binary.sh .devcontainer/scripts/build-arch-package.sh
```

Result: passed.

### Missing binary failure

```bash
.devcontainer/scripts/build-arch-package.sh
```

Result: failed before container startup because the default exported binary was absent, with clear output:

```text
build-arch-package: plain Linux binary artifact not found at /home/kcnc/code/apps/nuclear/.worktrees/arch-pkgbuild-support/artifacts/linux-arch-bin/nuclear-music-player
Build and export the plain executable first:
  corepack pnpm --filter @nuclearplayer/player build:frontend
  cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml
  .devcontainer/scripts/export-linux-binary.sh
```

### Version consistency

```bash
node <<'EOF'
const fs = require('fs');
const pkg = require('./packages/player/package.json');
const tauri = require('./packages/player/src-tauri/tauri.conf.json');
const pkgbuild = fs.readFileSync('.devcontainer/arch-package/PKGBUILD', 'utf8');
const match = pkgbuild.match(/^pkgver=(.+)$/m);
if (!match) process.exit(1);
if (match[1] !== pkg.version || match[1] !== tauri.version) process.exit(1);
console.log('pkgver ' + match[1] + ' matches player and tauri version');
EOF
```

Result: passed; `pkgver 1.39.0 matches player and tauri version`.

### Containerized makepkg mechanics

A real exported release binary was not present. To verify package assembly mechanics without host installs, a synthetic executable was created at the ignored repo-local path `artifacts/arch-package-test/input/nuclear-music-player`, and the helper was run with repo-local overrides:

```bash
ARCH_PACKAGE_BINARY="$(pwd)/artifacts/arch-package-test/input/nuclear-music-player" \
ARCH_PACKAGE_ARTIFACT_DIR="$(pwd)/artifacts/arch-package-test/out" \
.devcontainer/scripts/build-arch-package.sh
```

First attempt reached non-root `makepkg` but failed dependency checks because runtime deps are intentionally not installed in the container. The helper was updated to run `makepkg -d` for this already-built binary package while keeping runtime deps declared in `PKGBUILD`.

Second attempt passed. Relevant output:

```text
==> Making package: nuclear-player-bin 1.39.0-1 (Tue Jun  2 03:07:13 2026)
==> WARNING: Skipping dependency checks.
==> Retrieving sources...
  -> Found nuclear-music-player
  -> Found com.nuclearplayer.Nuclear.desktop
  -> Found com.nuclearplayer.Nuclear.png
  -> Found LICENSE
==> Entering fakeroot environment...
==> Starting package()...
==> Creating package "nuclear-player-bin"...
==> Finished making: nuclear-player-bin 1.39.0-1 (Tue Jun  2 03:07:13 2026)
Arch package artifacts written under /home/kcnc/code/apps/nuclear/.worktrees/arch-pkgbuild-support/artifacts/arch-package-test/out/packages
/home/kcnc/code/apps/nuclear/.worktrees/arch-pkgbuild-support/artifacts/arch-package-test/out/packages/nuclear-player-bin-1.39.0-1-x86_64.pkg.tar.zst
```

Synthetic package artifact path:

```text
artifacts/arch-package-test/out/packages/nuclear-player-bin-1.39.0-1-x86_64.pkg.tar.zst
```

### Package content inspection

```bash
pkg=artifacts/arch-package-test/out/packages/nuclear-player-bin-1.39.0-1-x86_64.pkg.tar.zst
tar -tf "$pkg" | grep -E '(^usr/bin/nuclear-music-player$|^usr/share/applications/com\.nuclearplayer\.Nuclear\.desktop$|^usr/share/icons/hicolor/512x512/apps/com\.nuclearplayer\.Nuclear\.png$|^usr/share/licenses/nuclear-player/LICENSE$|^\.PKGINFO$)'
tar -xOf "$pkg" .PKGINFO | grep -E '^(pkgname|pkgver|depend|optdepend|provides|conflict) = '
```

Result: passed. Matched package contents:

```text
.PKGINFO
usr/bin/nuclear-music-player
usr/share/applications/com.nuclearplayer.Nuclear.desktop
usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.Nuclear.png
usr/share/licenses/nuclear-player/LICENSE
```

Matched package metadata:

```text
pkgname = nuclear-player-bin
pkgver = 1.39.0-1
conflict = nuclear-player
conflict = nuclear-player-git
provides = nuclear-player
provides = nuclear-music-player
depend = webkit2gtk-4.1
depend = gtk3
depend = hicolor-icon-theme
depend = gst-plugins-base
depend = gst-plugins-good
optdepend = gst-plugins-bad: additional media codec support
optdepend = gst-plugins-ugly: patented codec support
optdepend = gst-libav: FFmpeg-based codec support
```

### Shellcheck

```bash
if command -v shellcheck >/dev/null 2>&1; then shellcheck .devcontainer/scripts/export-linux-binary.sh .devcontainer/scripts/build-arch-package.sh; else echo 'shellcheck not installed; skipped'; fi
```

Result: skipped; `shellcheck not installed; skipped`.

## Limitations

- A real `artifacts/linux-arch-bin/nuclear-music-player` release binary was not present, and `packages/player/src-tauri/target/release/nuclear-music-player` was also absent, so the successful package build used a synthetic executable only to prove helper/PKGBUILD mechanics and package contents.
- The generated package artifact under `artifacts/arch-package-test/` is ignored by git and should not be treated as a real Nuclear package.

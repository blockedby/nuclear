# Verification: Arch Nuclear fork identity slice

## Commands
### bash syntax
PASS bash -n .devcontainer/scripts/build-arch-package.sh
PASS bash -n .devcontainer/scripts/export-linux-binary.sh

### Workflow shell extraction check
PASS release-arch-package.yml required release/package wiring present

### PKGBUILD identity check
PASS PKGBUILD required fork identity strings present

### Arch package container build smoke test
Using repo-local smoke executable at artifacts/linux-arch-bin-test/nuclear-music-player-arch because no prebuilt release binary exists under artifacts/linux-arch-bin/.
:: Synchronizing package databases...
 core downloading...
 extra downloading...
 there is nothing to do
==> Making package: arch-nuclear-bin 1.39.0-1 (Tue Jun  2 07:22:23 2026)
==> Retrieving sources...
  -> Found nuclear-music-player-arch
  -> Found com.nuclearplayer.Nuclear.desktop
  -> Found com.nuclearplayer.Nuclear.png
  -> Found LICENSE
==> Validating source files with sha256sums...
==> Extracting sources...
==> Entering fakeroot environment...
==> Starting package()...
==> Tidying install...
  -> Removing libtool files...
  -> Removing static library files...
  -> Purging unwanted files...
  -> Compressing man and info pages...
==> Checking for packaging issues...
==> Creating package "arch-nuclear-bin"...
  -> Generating .PKGINFO file...
  -> Generating .BUILDINFO file...
  -> Generating .MTREE file...
  -> Compressing package...
==> Leaving fakeroot environment.
==> Finished making: arch-nuclear-bin 1.39.0-1 (Tue Jun  2 07:22:24 2026)
Arch package artifacts written under /home/kcnc/code/apps/nuclear/.worktrees/arch-nuclear-identity/artifacts/arch-package-smoke/packages
/home/kcnc/code/apps/nuclear/.worktrees/arch-nuclear-identity/artifacts/arch-package-smoke/packages/arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst

### Package contents inspection
Package artifact: artifacts/arch-package-smoke/packages/arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst
.BUILDINFO
.MTREE
.PKGINFO
usr/
usr/bin/
usr/bin/nuclear-music-player-arch
usr/share/
usr/share/applications/
usr/share/applications/com.nuclearplayer.desktop
usr/share/icons/
usr/share/icons/hicolor/
usr/share/icons/hicolor/512x512/
usr/share/icons/hicolor/512x512/apps/
usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.Nuclear.png
usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.png
usr/share/icons/hicolor/512x512/apps/nuclear-music-player-arch.png
usr/share/icons/hicolor/512x512/apps/nuclear-music-player.png
usr/share/licenses/
usr/share/licenses/arch-nuclear-bin/
usr/share/licenses/arch-nuclear-bin/LICENSE

### Required package entries check
usr/bin/nuclear-music-player-arch
usr/share/applications/com.nuclearplayer.desktop
usr/share/licenses/arch-nuclear-bin/LICENSE
Exec=nuclear-music-player-arch %u

### Git commit and initial push evidence
Commit: 7354d4ae9d2bd7718e443aab30da7c17d11aaa88
origin	https://github.com/blockedby/arch-nuclear.git (fetch)
origin	https://github.com/blockedby/arch-nuclear.git (push)
upstream	https://github.com/nukeop/nuclear.git (fetch)
upstream	DISABLED (push)
branch 'arch-nuclear-identity' set up to track 'origin/arch-nuclear-identity'.

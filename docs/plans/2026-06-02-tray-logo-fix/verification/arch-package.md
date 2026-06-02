# Arch logo/package metadata verification

## Scope

Verified the scoped Arch package/runtime metadata changes for desktop identity and hicolor icon lookup names. No host packages were installed. The package build used the existing repo-local container helper and a synthetic executable because no real exported release binary was present in this worktree.

## Diagnosis evidence

- `packages/player/src-tauri/tauri.conf.json` previously had identifier `com.nuclearplayer` but no `app.enableGTKAppId`, so Tauri did not pass the identifier as the GTK app id on Linux.
- `.devcontainer/arch-package/PKGBUILD` previously installed one icon lookup name only: `/usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.Nuclear.png`.
- `packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop` uses `Icon=com.nuclearplayer.Nuclear` and `StartupWMClass=Nuclear`; the Arch package now installs a patched Arch-specific desktop entry matching the Tauri GTK app id.

## RED check

```bash
node <<'EOF'
const fs = require('fs');
const tauri = JSON.parse(fs.readFileSync('packages/player/src-tauri/tauri.conf.json', 'utf8'));
const pkgbuild = fs.readFileSync('.devcontainer/arch-package/PKGBUILD', 'utf8');
if (tauri.identifier !== 'com.nuclearplayer') throw new Error(`unexpected identifier ${tauri.identifier}`);
if (tauri.app?.enableGTKAppId !== true) throw new Error('tauri app.enableGTKAppId is not true');
for (const expected of [
  '/usr/share/applications/com.nuclearplayer.desktop',
  '/usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.png',
  '/usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.Nuclear.png',
  '/usr/share/icons/hicolor/512x512/apps/nuclear-music-player.png',
]) {
  if (!pkgbuild.includes(expected)) throw new Error(`PKGBUILD missing ${expected}`);
}
if (!pkgbuild.includes('Icon=com.nuclearplayer')) throw new Error('PKGBUILD does not patch Icon=com.nuclearplayer');
if (!pkgbuild.includes('StartupWMClass=com.nuclearplayer')) throw new Error('PKGBUILD does not patch StartupWMClass=com.nuclearplayer');
console.log('arch app-id/icon metadata shape ok');
EOF
```

Result before implementation: failed as expected with:

```text
Error: tauri app.enableGTKAppId is not true
```

## Static green check

```bash
node <<'EOF'
const fs = require('fs');
const tauri = JSON.parse(fs.readFileSync('packages/player/src-tauri/tauri.conf.json', 'utf8'));
const pkgbuild = fs.readFileSync('.devcontainer/arch-package/PKGBUILD', 'utf8');
if (tauri.identifier !== 'com.nuclearplayer') throw new Error(`unexpected identifier ${tauri.identifier}`);
if (tauri.app?.enableGTKAppId !== true) throw new Error('tauri app.enableGTKAppId is not true');
if (!pkgbuild.includes('/usr/share/applications/com.nuclearplayer.desktop')) throw new Error('PKGBUILD missing com.nuclearplayer desktop install');
if (!pkgbuild.includes('/usr/share/icons/hicolor/512x512/apps/${icon_name}.png')) throw new Error('PKGBUILD missing hicolor icon install loop');
for (const iconName of ['com.nuclearplayer', 'com.nuclearplayer.Nuclear', 'nuclear-music-player']) {
  if (!pkgbuild.includes(iconName)) throw new Error(`PKGBUILD missing icon lookup name ${iconName}`);
}
if (!pkgbuild.includes('Icon=com.nuclearplayer')) throw new Error('PKGBUILD does not patch Icon=com.nuclearplayer');
if (!pkgbuild.includes('StartupWMClass=com.nuclearplayer')) throw new Error('PKGBUILD does not patch StartupWMClass=com.nuclearplayer');
console.log('arch app-id/icon metadata shape ok');
EOF
```

Result: passed.

```text
arch app-id/icon metadata shape ok
```

## Container package build

A real exported release binary was absent, so a synthetic executable was used only to verify package assembly and metadata contents:

```bash
set -euo pipefail
mkdir -p artifacts/arch-package-test/input
cat > artifacts/arch-package-test/input/nuclear-music-player <<'EOF'
#!/usr/bin/env sh
echo synthetic nuclear
EOF
chmod +x artifacts/arch-package-test/input/nuclear-music-player
ARCH_PACKAGE_BINARY="$(pwd)/artifacts/arch-package-test/input/nuclear-music-player" \
ARCH_PACKAGE_ARTIFACT_DIR="$(pwd)/artifacts/arch-package-test/out" \
.devcontainer/scripts/build-arch-package.sh
```

Result: passed. Relevant output:

```text
==> Making package: nuclear-player-bin 1.39.0-1 (Tue Jun  2 03:48:28 2026)
==> WARNING: Skipping dependency checks.
==> Retrieving sources...
  -> Found nuclear-music-player
  -> Found com.nuclearplayer.Nuclear.desktop
  -> Found com.nuclearplayer.Nuclear.png
  -> Found LICENSE
==> Starting package()...
==> Creating package "nuclear-player-bin"...
==> Finished making: nuclear-player-bin 1.39.0-1 (Tue Jun  2 03:48:29 2026)
Arch package artifacts written under /home/kcnc/code/apps/nuclear/.worktrees/tray-logo-fix/artifacts/arch-package-test/out/packages
/home/kcnc/code/apps/nuclear/.worktrees/tray-logo-fix/artifacts/arch-package-test/out/packages/nuclear-player-bin-1.39.0-1-x86_64.pkg.tar.zst
```

Synthetic package artifact path:

```text
artifacts/arch-package-test/out/packages/nuclear-player-bin-1.39.0-1-x86_64.pkg.tar.zst
```

## Package metadata/content inspection

```bash
set -euo pipefail
pkg=artifacts/arch-package-test/out/packages/nuclear-player-bin-1.39.0-1-x86_64.pkg.tar.zst
python <<'EOF'
import configparser
import io
import json
import subprocess
pkg = 'artifacts/arch-package-test/out/packages/nuclear-player-bin-1.39.0-1-x86_64.pkg.tar.zst'
entries = set(subprocess.check_output(['tar', '-tf', pkg], text=True).splitlines())
desktop = subprocess.check_output(['tar', '-xOf', pkg, 'usr/share/applications/com.nuclearplayer.desktop'], text=True)
parser = configparser.ConfigParser(interpolation=None)
parser.read_file(io.StringIO(desktop))
entry = parser['Desktop Entry']
icon = entry['Icon']
startup_wm_class = entry['StartupWMClass']
expected_icon = f'usr/share/icons/hicolor/512x512/apps/{icon}.png'
if expected_icon not in entries:
    raise SystemExit(f'Icon does not resolve to installed package entry: {expected_icon}')
tauri = json.load(open('packages/player/src-tauri/tauri.conf.json'))
identifier = tauri['identifier']
if tauri['app'].get('enableGTKAppId') is not True:
    raise SystemExit('enableGTKAppId is not true')
if icon != identifier or startup_wm_class != identifier:
    raise SystemExit(f'desktop identity mismatch icon={icon} startup={startup_wm_class} identifier={identifier}')
for icon_name in [identifier, 'com.nuclearplayer.Nuclear', 'nuclear-music-player']:
    path = f'usr/share/icons/hicolor/512x512/apps/{icon_name}.png'
    if path not in entries:
        raise SystemExit(f'missing icon alias {path}')
print(f'desktop icon {icon} resolves to {expected_icon}; StartupWMClass matches Tauri GTK app id {identifier}')
EOF
```

Result: passed.

```text
desktop icon com.nuclearplayer resolves to usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.png; StartupWMClass matches Tauri GTK app id com.nuclearplayer
```

Additional archive inspection:

```text
Desktop metadata:
Exec=nuclear-music-player %u
Icon=com.nuclearplayer
StartupWMClass=com.nuclearplayer

Package entries:
.PKGINFO
usr/bin/nuclear-music-player
usr/share/applications/com.nuclearplayer.desktop
usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.Nuclear.png
usr/share/icons/hicolor/512x512/apps/com.nuclearplayer.png
usr/share/icons/hicolor/512x512/apps/nuclear-music-player.png
usr/share/licenses/nuclear-player/LICENSE

Icon file signatures:
com.nuclearplayer: 89 50 4e 47 0d 0a 1a 0a
com.nuclearplayer.Nuclear: 89 50 4e 47 0d 0a 1a 0a
nuclear-music-player: 89 50 4e 47 0d 0a 1a 0a
```

## Quality checks

```bash
bash -n .devcontainer/scripts/export-linux-binary.sh .devcontainer/scripts/build-arch-package.sh
node -e "JSON.parse(require('fs').readFileSync('packages/player/src-tauri/tauri.conf.json','utf8')); console.log('tauri config JSON ok')"
```

Result: passed.

```text
tauri config JSON ok
```

## Limitations / user reinstall notes

- The package build used a synthetic executable because no real `artifacts/linux-arch-bin/nuclear-music-player` or `packages/player/src-tauri/target/release/nuclear-music-player` was present locally. Rebuild with a real release binary before distribution.
- The runtime Wayland app id depends on rebuilding the binary after `app.enableGTKAppId` is enabled in Tauri config.
- After installing the rebuilt Arch package, users may need to refresh desktop/icon caches or log out/in. Useful commands on Arch include `sudo pacman -U <package>`, `gtk-update-icon-cache -f /usr/share/icons/hicolor` if available, and restarting the shell/session if it cached the old generic icon.

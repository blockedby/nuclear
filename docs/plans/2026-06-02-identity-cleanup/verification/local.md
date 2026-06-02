# Local verification

Commands run 2026-06-02 from `/home/kcnc/code/apps/nuclear/.worktrees/identity-cleanup`.

## Config parse

```sh
python - <<'PY'
import json, xml.etree.ElementTree as ET
json.load(open('packages/player/src-tauri/tauri.conf.json'))
ET.parse('packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.metainfo.xml')
print('json/xml parse ok')
PY
```

Result: passed (`json/xml parse ok`).

## Identity decision evidence

```sh
grep -n "productName\|mainBinaryName\|identifier\|endpoints" packages/player/src-tauri/tauri.conf.json
grep -n "Exec=\|Icon=\|StartupWMClass" packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop
grep -n "url type=\"bugtracker\"\|url type=\"vcs-browser\"" packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.metainfo.xml
grep -n "repository" packages/player/src-tauri/Cargo.toml
grep -RIn "github.com/nukeop/nuclear" packages/player/src-tauri/tauri.conf.json packages/player/src-tauri/Cargo.toml packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.metainfo.xml || true
```

Result: passed.
- Tauri product/user-data-sensitive identifiers remain unchanged: `productName: Nuclear`, `mainBinaryName: nuclear-music-player`, `identifier: com.nuclearplayer`.
- Desktop source remains upstream-compatible: `Exec=nuclear-music-player %u`, `Icon=com.nuclearplayer.Nuclear`, `StartupWMClass=Nuclear`; Arch package patching remains in `.devcontainer/arch-package/PKGBUILD`.
- Fork metadata aligned: updater endpoint, Cargo repository, AppStream bugtracker, and AppStream VCS point to `blockedby/arch-nuclear`.
- Critical changed metadata files no longer contain `github.com/nukeop/nuclear`.

## Full checks

Not run. Change is limited to JSON/XML/TOML URL metadata and task-package docs. No TS/Rust behavior, generated routes, dependency graph, or packaging scripts changed.

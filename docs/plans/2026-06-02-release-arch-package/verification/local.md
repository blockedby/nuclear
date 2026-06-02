# Local verification

## 2026-06-02

Commands run from `/home/kcnc/code/apps/nuclear/.worktrees/release-arch-package`.

### Package validation script positive/negative checks

```bash
rm -rf artifacts/validation-test
mkdir -p artifacts/validation-test/good/usr/bin artifacts/validation-test/good/usr/share/applications artifacts/validation-test/packages
printf '#!/bin/sh\n' > artifacts/validation-test/good/usr/bin/nuclear-music-player-arch
chmod +x artifacts/validation-test/good/usr/bin/nuclear-music-player-arch
printf '[Desktop Entry]\nExec=nuclear-music-player-arch %%u\n' > artifacts/validation-test/good/usr/share/applications/com.nuclearplayer.desktop
tar --zstd -cf artifacts/validation-test/packages/arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst -C artifacts/validation-test/good usr
.devcontainer/scripts/validate-arch-package.sh "$PWD/artifacts/validation-test/packages"
```

Result: passed. Output included:

```text
Validating Arch package .../arch-nuclear-bin-1.39.0-1-x86_64.pkg.tar.zst
Validated 1 Arch package artifact(s) under .../artifacts/validation-test/packages
```

Negative desktop Exec check:

```bash
# built a synthetic package with Exec=nuclear-music-player %u
.devcontainer/scripts/validate-arch-package.sh "$PWD/artifacts/validation-test/packages"
```

Result: failed as expected. Output included:

```text
validate-arch-package: .../bad.pkg.tar.zst desktop file does not contain 'Exec=nuclear-music-player-arch %u'
negative validation failed as expected
```

### Static workflow/docs/script checks

```bash
grep -q 'Validate Arch package contents' .github/workflows/release-arch-package.yml
grep -q 'artifacts/arch-package/packages/\*.pkg.tar.zst' .github/workflows/release-arch-package.yml
grep -q 'workflow_dispatch' .github/workflows/release-arch-package.yml
grep -q 'arch-nuclear@\*\.\*\.\*' .devcontainer/docs/arch-linux-package.md
grep -q 'Exec=nuclear-music-player-arch %u' .devcontainer/docs/arch-linux-package.md
bash -n .devcontainer/scripts/validate-arch-package.sh .devcontainer/scripts/build-arch-package.sh .devcontainer/scripts/export-linux-binary.sh
```

Result: passed.

### Not run / explicit gaps

- Full GitHub Actions execution was not run locally.
- Full real Arch package build in Docker/Podman was not run to avoid pulling/running container dependencies in this slice; the validation script was proven against synthetic `.pkg.tar.zst` fixtures and is wired after the existing container package build step.

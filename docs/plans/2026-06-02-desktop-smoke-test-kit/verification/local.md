# Local verification

Fresh owner verification on 2026-06-02:

```bash
bash -n .devcontainer/scripts/build-branch-arch-package.sh \
  .devcontainer/scripts/export-linux-binary.sh \
  .devcontainer/scripts/build-arch-package.sh \
  .devcontainer/scripts/validate-arch-package.sh
```

Result: passed.

```bash
grep -R "roadmap/wayland-tray-options\|roadmap/mpris2-now-playing\|/usr/bin/nuclear-music-player-arch\|sudo pacman -Rns arch-nuclear-bin" \
  -n .devcontainer/docs/desktop-smoke-test-kit.md
```

Result: passed; docs include both branch commands, installed binary path, and rollback command.

Expensive frontend/cargo/package builds were intentionally not run per task scope.

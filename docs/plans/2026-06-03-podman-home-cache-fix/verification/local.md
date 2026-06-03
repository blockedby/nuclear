# Local verification: Podman HOME/cache permission fix

## Targeted checks

### Shell syntax

Command:

```bash
bash -n tools/podman-gui/podman-gui-smoke
```

Result: passed with no output.

### Help output

Command:

```bash
tools/podman-gui/podman-gui-smoke --help
```

Result: passed. Output began:

```text
Usage: tools/podman-gui/podman-gui-smoke <command> [args]

Commands:
  build-image                 Build the Arch GUI smoke image with rootless podman.
  shell [--branch BRANCH]     Open a shell in the mounted current checkout.
```

### Container HOME/Corepack cache smoke

Command:

```bash
tools/podman-gui/podman-gui-smoke run -- bash -lc 'id; mkdir -p "$HOME/.cache/node/corepack/v1"; test -w "$HOME/.cache/node/corepack/v1"'
```

Result: passed. Podman warned that this non-interactive terminal is not a TTY, then the command printed the container user and completed successfully:

```text
time="2026-06-03T17:41:29+03:00" level=warning msg="The input device is not a TTY. The --tty and --interactive flags might not work properly"
uid=1000(kcnc) gid=1000(kcnc) groups=1000(kcnc)
```

## Static checks

### Writable runtime HOME mount

Command:

```bash
python - <<'PY'
from pathlib import Path
text = Path('tools/podman-gui/podman-gui-smoke').read_text()
required = [
    'create_runtime_home()',
    'prepare_runtime_home "$runtime_home"',
    'args+=(--volume "$runtime_home:/tmp/arch-nuclear-home:rw")',
    '"$runtime_home/.cache/node/corepack"',
    'local setup="test -w /tmp/arch-nuclear-home"',
]
missing = [item for item in required if item not in text]
if missing:
    print('missing writable HOME evidence:')
    print('\n'.join(missing))
    raise SystemExit(1)
print('host-created writable runtime HOME/cache is mounted to /tmp/arch-nuclear-home')
PY
```

Result: passed.

```text
host-created writable runtime HOME/cache is mounted to /tmp/arch-nuclear-home
```

### Read-only desktop theme/icon/font mounts

Command:

```bash
python - <<'PY'
from pathlib import Path
text = Path('tools/podman-gui/podman-gui-smoke').read_text()
required = [
    'add_read_only_mount_if_present "$HOME/.config/gtk-3.0" "/tmp/arch-nuclear-home/.config/gtk-3.0"',
    'add_read_only_mount_if_present "$HOME/.config/gtk-4.0" "/tmp/arch-nuclear-home/.config/gtk-4.0"',
    'add_read_only_mount_if_present "$HOME/.config/kdeglobals" "/tmp/arch-nuclear-home/.config/kdeglobals"',
    'add_read_only_mount_if_present "$HOME/.config/Kvantum" "/tmp/arch-nuclear-home/.config/Kvantum"',
    'add_read_only_mount_if_present "$HOME/.local/share/icons" "/tmp/arch-nuclear-home/.local/share/icons"',
    'add_read_only_mount_if_present "$HOME/.local/share/fonts" "/tmp/arch-nuclear-home/.local/share/fonts"',
    'add_read_only_mount_if_present "$HOME/.icons" "/tmp/arch-nuclear-home/.icons"',
    'add_read_only_mount_if_present "$HOME/.themes" "/tmp/arch-nuclear-home/.themes"',
    'printf \'%s\\0\' --volume "$host_path:$container_path:ro"',
]
missing = [item for item in required if item not in text]
if missing:
    print('missing read-only desktop mount evidence:')
    print('\n'.join(missing))
    raise SystemExit(1)
print('desktop theme/icon/font mounts still route through :ro helper under /tmp/arch-nuclear-home')
PY
```

Result: passed.

```text
desktop theme/icon/font mounts still route through :ro helper under /tmp/arch-nuclear-home
```

### No docker.sock or upstream writes in touched runner/docs

Command:

```bash
python - <<'PY'
from pathlib import Path
paths = [Path('tools/podman-gui/podman-gui-smoke'), Path('docs/development/rootless-podman-gui-smoke.md')]
forbidden = ['--volume /var/run/docker.sock', '--volume /run/docker.sock', 'git push', 'github.com/nukeop', 'nukeop/nuclear']
violations = []
for path in paths:
    text = path.read_text()
    for token in forbidden:
        if token in text:
            violations.append(f'{path}: {token}')
if violations:
    print('\n'.join(violations))
    raise SystemExit(1)
print('no docker socket mounts, upstream remote writes, or git push commands in touched runner/docs')
PY
```

Result: passed.

```text
no docker socket mounts, upstream remote writes, or git push commands in touched runner/docs
```

## Owner re-check before master commit

Commands run from `/home/kcnc/code/apps/nuclear` on `master`:

```bash
bash -n tools/podman-gui/podman-gui-smoke
tools/podman-gui/podman-gui-smoke --help >/tmp/podman-gui-help-owner.txt
tools/podman-gui/podman-gui-smoke run -- bash -lc 'id; mkdir -p "$HOME/.cache/node/corepack/v1"; test -w "$HOME/.cache/node/corepack/v1"'
```

Result: passed. Container smoke printed `uid=1000(kcnc) gid=1000(kcnc) groups=1000(kcnc)` and only emitted the known non-fatal non-TTY Podman warning.

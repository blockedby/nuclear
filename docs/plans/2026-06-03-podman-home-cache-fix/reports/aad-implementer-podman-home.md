PI_RESULT: PASS
TASK: Podman HOME/cache permission fix
TASK_PACKAGE: docs/plans/2026-06-03-podman-home-cache-fix
REPORT_PATH: docs/plans/2026-06-03-podman-home-cache-fix/reports/aad-implementer-podman-home.md
PROGRESS_PATH: docs/plans/2026-06-03-podman-home-cache-fix/progress/aad-implementer-podman-home.md
COMMITS:
- not committed: delegated prompt explicitly says do not commit/push; changes left for owner
FILES_CHANGED:
- tools/podman-gui/podman-gui-smoke: creates a temporary host runtime HOME, pre-creates cache/Cargo parent paths, mounts it read/write to `/tmp/arch-nuclear-home`, and checks that container HOME is writable before running requested commands
- docs/development/rootless-podman-gui-smoke.md: documents the ephemeral writable runtime HOME and clarifies that existing theme/icon/font mounts stay read-only under container HOME
- docs/plans/2026-06-03-podman-home-cache-fix/verification/local.md: records local verification commands and outputs
- docs/plans/2026-06-03-podman-home-cache-fix/progress/aad-implementer-podman-home.md: records implementation progress
- docs/plans/2026-06-03-podman-home-cache-fix/plan.md: appends Task 1 ledger entry
- docs/plans/2026-06-03-podman-home-cache-fix/reports/aad-implementer-podman-home.md: final implementation report
AC_VERIFICATION:
- Runner mounts a host-created writable HOME to `/tmp/arch-nuclear-home`: static check verified `create_runtime_home`, `prepare_runtime_home`, pre-created Corepack cache path, `--volume "$runtime_home:/tmp/arch-nuclear-home:rw"`, and startup `test -w /tmp/arch-nuclear-home` — passed
- Corepack cache mkdir succeeds inside container: `tools/podman-gui/podman-gui-smoke run -- bash -lc 'id; mkdir -p "$HOME/.cache/node/corepack/v1"; test -w "$HOME/.cache/node/corepack/v1"'` printed `uid=1000(kcnc) gid=1000(kcnc) groups=1000(kcnc)` and exited successfully; Podman also emitted a non-fatal non-TTY warning — passed
- Existing read-only theme/icon/font mounts remain read-only under container HOME: static check verified GTK 3/4, kdeglobals, Kvantum, icons, fonts, `.icons`, and `.themes` still route through `add_read_only_mount_if_present`, whose volume output keeps `:ro`, with targets under `/tmp/arch-nuclear-home` — passed
TESTS_RUN:
- RED static check for explicit writable HOME mount before production change: failed as expected with exit 42 (`expected red: no explicit writable HOME volume mount to /tmp/arch-nuclear-home`)
- `bash -n tools/podman-gui/podman-gui-smoke`: passed
- `tools/podman-gui/podman-gui-smoke --help`: passed
- `tools/podman-gui/podman-gui-smoke run -- bash -lc 'id; mkdir -p "$HOME/.cache/node/corepack/v1"; test -w "$HOME/.cache/node/corepack/v1"'`: passed with non-fatal Podman TTY warning
- Static writable HOME/cache Python check: passed
- Static read-only desktop mounts Python check: passed
- Static no docker socket/upstream writes Python check across touched runner/docs: passed
QUALITY_CHECKS:
- Shell syntax: `bash -n tools/podman-gui/podman-gui-smoke` passed
- Runtime smoke: owner-provided Podman run/Corepack mkdir command passed locally
- Static safety checks: read-only desktop mount check and no docker.sock/upstream write check passed
- Broad repo lint/typecheck/build: not run; delegated scope is shell runner/docs only and owner requested lightweight local checks
QUALITY_NOTES:
- Readability/reuse: followed existing `podman_mount_args`, `add_read_only_mount_if_present`, and `run_container` structure; added only small local shell helpers for runtime HOME creation/preparation
- Error handling/logging: preserved existing fail-fast shell style; `run_container` now captures Podman status to remove the temporary runtime HOME before returning the original status
- Backend/API/data: not relevant; no backend/API/storage/data paths touched
- Frontend/UI: not relevant; no UI paths touched
- DevOps/runtime: runtime HOME is host-created with `mktemp -d`, cache/Cargo parent paths are pre-created, mounted before nested read-only desktop mounts, and removed after container exit; no CI/deployment workflow changes
- Security: no secrets or private env values logged; no new privileged mounts; existing rootless Podman, keep-id user namespace, GUI socket exposure, and read-only desktop config behavior preserved
- Concurrency/idempotency: each run gets a distinct temporary HOME directory, avoiding reuse/races between simultaneous runner invocations; cleanup removes only the mktemp-created directory
- Compatibility/performance: existing CLI commands/options/env names preserved; runtime HOME caches are ephemeral by design, so no persistent cache performance guarantee added or removed for the mounted checkout
SIDE_FINDINGS:
- Blocking: none
- Non-blocking follow-up candidates: consider adding a non-interactive/no-tty runner mode later if automated Podman checks should avoid the current `-it` warning; outside this task
NOTES: Verification details are in `docs/plans/2026-06-03-podman-home-cache-fix/verification/local.md`. No commit was made per delegated do-not-commit boundary.

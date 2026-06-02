# Local verification

Fresh checks run from `/home/kcnc/code/apps/nuclear/.worktrees/smoke-test-kit` on 2026-06-02.

- `bash -n .devcontainer/scripts/smoke-build-install.sh`: passed; no output.
- `.devcontainer/scripts/smoke-build-install.sh --help`: passed; printed usage, examples, alias targets, pacman install step, and rollback command.
- `.devcontainer/scripts/smoke-build-install.sh bogus >/tmp/smoke-bogus.out 2>&1; code=$?; cat /tmp/smoke-bogus.out; echo EXIT:$code; test $code -ne 0`: passed; printed usage plus `smoke-build-install: unknown target: bogus`, `EXIT:1`.

Build/install was intentionally not run per task constraint.

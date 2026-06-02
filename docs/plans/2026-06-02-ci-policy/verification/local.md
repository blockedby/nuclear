# Local verification: CI policy and draft PR gating

## 2026-06-02 static workflow policy checks

### RED before implementation

Command:

```bash
python - <<'PY'
# Parsed .github/workflows/ci.yml with PyYAML and asserted:
# - ci job has draft PR guard
# - ordinary ci job does not contain pnpm build or tauri build
# - ordinary ci job contains lint/test/type-check/player frontend build/cargo check/cargo test
# - a full build job is available only through workflow_dispatch
PY
```

Result: failed as expected on the pre-change workflow:

```text
AssertionError: ordinary ci contains forbidden command: pnpm build
```

### GREEN after implementation

Command:

```bash
python - <<'PY'
from pathlib import Path
import re
import yaml

workflow = yaml.safe_load(Path('.github/workflows/ci.yml').read_text())
jobs = workflow.get('jobs', {})
ci = jobs.get('ci')
assert ci, 'missing ci job'
ci_if = str(ci.get('if', ''))
assert "github.event_name != 'pull_request'" in ci_if and 'github.event.pull_request.draft == false' in ci_if
ci_runs = '\n'.join(str(step.get('run', '')) for step in ci.get('steps', []) if isinstance(step, dict))
for forbidden in ('pnpm build', 'tauri build'):
    assert forbidden not in ci_runs
for required in (
    'pnpm lint',
    'pnpm test',
    'pnpm type-check',
    'pnpm --filter @nuclearplayer/player build:frontend',
    'cargo check',
    'cargo test',
):
    assert required in ci_runs
full_build_jobs = []
for job_name, job in jobs.items():
    if not isinstance(job, dict):
        continue
    job_runs = '\n'.join(str(step.get('run', '')) for step in job.get('steps', []) if isinstance(step, dict))
    if re.search(r'pnpm build|tauri build', job_runs):
        full_build_jobs.append((job_name, str(job.get('if', '')), job_runs))
assert any("github.event_name == 'workflow_dispatch'" in job_if for _, job_if, _ in full_build_jobs)
print('workflow policy assertions passed')
PY
```

Result:

```text
workflow policy assertions passed
```

### Command/condition inspection

Command:

```bash
grep -n -C 2 -E 'pnpm build|tauri build|build:frontend|cargo check|cargo test|draft == false|workflow_dispatch' .github/workflows/ci.yml
```

Relevant findings:

```text
9:  workflow_dispatch:
20:    if: github.event_name != 'pull_request' || github.event.pull_request.draft == false
80:        run: pnpm --filter @nuclearplayer/player build:frontend
83:        run: cargo check
87:        run: cargo test
91:    if: github.event_name == 'workflow_dispatch'
142:        run: pnpm build
```

Interpretation: the ordinary `ci` job is draft-gated and contains the PR-safe lint/test/type-check/frontend/Rust commands only. The only `pnpm build` production bundle path in `.github/workflows/ci.yml` is in `production-build`, which is gated to `workflow_dispatch`.

### Release/manual full-build path inspection

Command:

```bash
grep -R -n -E 'workflow_dispatch|draft == false|pnpm build|tauri-action|cargo build --release|build:frontend|cargo check|cargo test' .github/workflows/ci.yml .github/workflows/release-player.yml .github/workflows/release-arch-package.yml
```

Result excerpt:

```text
.github/workflows/ci.yml:9:  workflow_dispatch:
.github/workflows/ci.yml:20:    if: github.event_name != 'pull_request' || github.event.pull_request.draft == false
.github/workflows/ci.yml:80:        run: pnpm --filter @nuclearplayer/player build:frontend
.github/workflows/ci.yml:83:        run: cargo check
.github/workflows/ci.yml:87:        run: cargo test
.github/workflows/ci.yml:91:    if: github.event_name == 'workflow_dispatch'
.github/workflows/ci.yml:142:        run: pnpm build
.github/workflows/release-player.yml:110:        uses: tauri-apps/tauri-action@v0
.github/workflows/release-arch-package.yml:7:  workflow_dispatch:
.github/workflows/release-arch-package.yml:48:          corepack pnpm --filter @nuclearplayer/player build:frontend
.github/workflows/release-arch-package.yml:49:          cargo build --release --manifest-path packages/player/src-tauri/Cargo.toml
```

Interpretation: full production build coverage remains available through manual CI dispatch (`production-build` with `pnpm build`), the player release workflow (`tauri-apps/tauri-action@v0`), and the Arch package release/manual workflow (`cargo build --release`).

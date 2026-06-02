# Plan: Nuclear repo-local devcontainer + VitePlus container build

## Intake
Goal: fork and clone nukeop/nuclear, add safe repo-local Ubuntu 24.04 devcontainer config for Tauri Linux deps, Rust stable, and VitePlus read-only mount; run progressive setup/build commands in a non-privileged container.
In scope: `.devcontainer/` config and only safe fixes needed for container setup/build in this clone. Out of scope: upstream PR, host system dependency installs, destructive Docker cleanup, privileged/broad mounts, secret exposure.
Done: fork/clone evidence, safe container files, `vp env current`, `vp install`, feasible checks/builds attempted with classified failures and next commands.
Blocking unknowns: exact Tauri dependency set and whether full build is practical in this environment.

## Repo orientation
Nuclear is a pnpm monorepo/Turborepo Tauri desktop app. Local guidance: root `AGENTS.md`, `README.md`. Package manager: `pnpm@10.12.1` with `pnpm-lock.yaml`.
Likely files: `.devcontainer/Dockerfile`, `.devcontainer/compose.yml`, task package docs.
Verification commands: `git remote -v`, `gh repo view`, Docker compose config/build/run, container `vp env current`, `vp install`, `vp run pnpm ...`.

## Reuse discovery
Follow package manager from `package.json`/lockfile. Follow Tauri Linux dependency guidance through Ubuntu apt packages and Rust stable via rustup. Use VitePlus inside container by sourcing `/home/kcnc/.vite-plus/env`.

## Missing pieces
Add devcontainer Dockerfile, compose file with only repo mount, VitePlus ro mount, and named caches. Then build image and run progressive commands.

## Plan tasks
T1 Container config: add safe Ubuntu 24.04 non-root devcontainer config with Tauri deps, Rust stable, Node corepack support, VitePlus mount, named caches. Acceptance: files exist and safety scan shows no `/`, `$HOME`, docker.sock, privileged, broad mounts.
T2 Progressive container setup/build: build container; run `vp env current`, `vp install`, feasible checks, frontend build, attempt Tauri build if safe/practical. Acceptance: commands and outputs logged, failures classified and safe fixes applied only in clone/config.
T3 Final evidence/report: verify remotes/config/diff and write AC matrix and next commands.

## Dependency graph
Sequential: T1 -> T2 -> T3. Executor: slice owner directly for shell orchestration/config due external fork/container state; no sub-slicing.

## Execution ledger
- Fork created/existing: `https://github.com/blockedby/nuclear`.
- Clone path: `/home/kcnc/code/apps/nuclear`.
- T1 complete: `.devcontainer/Dockerfile` and `.devcontainer/compose.yml` added; safety grep found no privileged/docker.sock/broad host mounts.
- R-01: initial Docker build failed because Ubuntu 24.04 already has UID/GID 1000; fixed by using existing non-root `ubuntu` user.
- R-02: named node_modules/cargo/target cache mounts caused root-owned permission failures; fixed by keeping only repo mount, VitePlus read-only mount, and `nuclear-pnpm-store` named cache.
- R-03: Tauri AppImage bundling failed on missing `/usr/bin/xdg-open`; fixed by adding `xdg-utils`.
- T2 results: `vp env current`, `vp install`, recursive type-check, player frontend build all passed. Full Tauri build compiled and created deb/rpm/AppImage bundles, then exited nonzero because updater signing public key is configured but no `TAURI_SIGNING_PRIVATE_KEY` was provided.

## Follow-up: Arch plain binary deliverable
Goal: commit local container/evidence changes to the user's fork only and make the Linux deliverable preference explicit: plain executable binary for Arch use, not AppImage. Out of scope: upstream PR, host dependency installs, destructive cleanup, broad source changes, pacman package implementation.

Reuse discovery: Tauri config sets `mainBinaryName` to `nuclear-music-player`; Cargo/Tauri release builds place the plain ELF executable at `packages/player/src-tauri/target/release/nuclear-music-player`. Existing `tauri build` with `bundle.targets = "all"` emits AppImage/deb/rpm bundles and then fails signing without `TAURI_SIGNING_PRIVATE_KEY`; direct `cargo build --release` avoids Tauri bundling/signing and produces the plain binary.

Missing pieces resolved here: added `.devcontainer/scripts/export-linux-binary.sh` and `.devcontainer/docs/arch-linux-binary-artifact.md`; ignored generated `artifacts/`; exported current binary to `artifacts/linux-arch-bin/nuclear-music-player` for local evidence.

Acceptance criteria:
- AC1: Repo documents a plain Linux executable workflow that does not require AppImage as the deliverable.
- AC2: Tauri/Arch packaging limitation is explicit: current Tauri config does not produce pacman `pkg.tar.zst`; use PKGBUILD/separate packaging if required.
- AC3: Script can copy the release binary to a stable artifact directory when the binary exists.
- AC4: Changes are committed and pushed to user's `origin` fork only; no upstream PR.

Verification evidence:
- `file packages/player/src-tauri/target/release/nuclear-music-player`: ELF 64-bit x86-64 dynamically linked Linux executable.
- `.devcontainer/scripts/export-linux-binary.sh`: copied to `artifacts/linux-arch-bin/nuclear-music-player` (52M) and logged in `verification/arch-binary-export.txt`.

# Acceptance plan: Nuclear fork/container build audit

## Objective
Verify the fork/clone, repo-local devcontainer safety, VitePlus setup, and build evidence for the container build slice.

## Acceptance criteria to audit
1. GitHub auth/fork exists for the authenticated user; no upstream PR was created.
2. Local clone points at the fork remote and is present at `/home/kcnc/code/apps/nuclear`.
3. `.devcontainer/Dockerfile` and `.devcontainer/compose.yml` provide Ubuntu 24.04, Tauri Linux deps, Rust stable, VitePlus ro mount, non-root execution, and only allowed mounts.
4. Fresh container evidence exists for `vp env current`, `vp install`, lightweight checks, frontend build, and a safe/full Tauri build attempt.
5. Any failures are classified and the remaining limitation is explicit.
6. Final report includes fork URL, clone path, file list, commands/evidence, remaining issue(s), and exact next commands.

## Evidence sources to audit
- `docs/plans/2026-06-02-container-viteplus-build/verification/final-evidence.txt`
- `docs/plans/2026-06-02-container-viteplus-build/verification/compose-config.txt`
- `docs/plans/2026-06-02-container-viteplus-build/verification/logs/*.log`
- Current repo files: `.devcontainer/Dockerfile`, `.devcontainer/compose.yml`
- Fresh shell checks: `gh auth status`, `gh repo view blockedby/nuclear`, `git remote -v`, `git status --short`

## Audit notes
- Treat the signing-key failure in the final Tauri build as a runtime/secrets limitation, not a repo-local config bug, unless the repo explicitly documents a non-signing path.
- Prefer the freshest successful logs over stale early failures when the later run supersedes them.

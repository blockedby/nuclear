## Task
- Mission: Resolve issue #4 with migration-safe package/app identity cleanup or evidence closeout.
- Target: Arch Nuclear identity metadata in Tauri updater config, package/AppStream metadata, and documented identity decisions.
- Boundaries: No upstream PRs, no merge, no broad product/app-id/data-dir/icon migration.
- Done when: Identity decisions documented, safe metadata gaps fixed, PR or no-PR disposition recorded.
- Expected evidence: PR URL, branch/commits, verification commands, issue #4 linkage.

## Context
- Thread: Arch Nuclear roadmap separate PRs.
- Slice: D — package/app identity cleanup (#4).
- Task package: `docs/plans/2026-06-02-identity-cleanup`.
- Report path: `docs/plans/2026-06-02-identity-cleanup/reports/final.md`.
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/identity-cleanup`.
- Branch: `roadmap/identity-cleanup`.
- PR: https://github.com/blockedby/arch-nuclear/pull/6.
- Verify scope: URL/config/package metadata parse and grep audit; no UI/product text changed.

## Spec compliance
- Requirement / AC: Identity decisions are scoped, documented, and migration-safe.
  - Status: done.
  - Evidence: plan decision record; PR only changes updater/repository/AppStream URLs plus task package docs.
  - Gap if any: none.
- Requirement / AC: Existing user config/cache paths are not broken without a migration plan.
  - Status: done.
  - Evidence: Tauri `productName`, `identifier`, `mainBinaryName`, desktop source identity, icons, and app ids were not renamed.
  - Gap if any: none.
- Requirement / AC: PR is small and focused if changes are needed.
  - Status: done.
  - Evidence: PR #6, commits `3757813a` and `26d5ac19`; code/config diff limited to 3 metadata files.
  - Gap if any: none.
- Requirement / AC: Issue #4 linkage/disposition.
  - Status: done.
  - Evidence: PR body includes `Fixes #4` and migration-safety notes.
  - Gap if any: none.

## Acceptance verification
- AC1: Identity decisions are scoped, documented, and migration-safe.
  - Covered by: diff inspection and task-package decision record.
  - Result: passed.
  - Evidence: `docs/plans/2026-06-02-identity-cleanup/plan.md`; changed files are `tauri.conf.json`, `Cargo.toml`, `com.nuclearplayer.Nuclear.metainfo.xml`.
- AC2: Existing user config/cache paths are not broken without a migration plan.
  - Covered by: grep audit of Tauri/product/desktop identifiers.
  - Result: passed.
  - Evidence: `productName: Nuclear`, `identifier: com.nuclearplayer`, `mainBinaryName: nuclear-music-player`, source desktop `Exec/Icon/StartupWMClass` unchanged.
- AC3: PR is small/focused or no-PR evidence exists.
  - Covered by: PR #6 diff and commit list.
  - Result: passed.
  - Evidence: https://github.com/blockedby/arch-nuclear/pull/6.
- AC4: PR URL, branch/commit/checks, recommended merge notes.
  - Covered by: `gh pr view`.
  - Result: passed with CI pending/not reported yet.
  - Evidence: base `master`, head `roadmap/identity-cleanup`, commits `3757813a`, `26d5ac19`; statusCheckRollup empty immediately after final push.

## System readiness
- Routes / registration: not relevant.
- Services / APIs: updater endpoint now points to fork release metadata.
- Config / env / secrets: done; no secrets changed or committed.
- Permissions / access: done; branch pushed to origin only.
- Database / migrations: not relevant; no data path migration.
- Frontend-backend integration: not relevant.
- Runtime / deployment wiring: done for metadata scope; release publication still must provide compatible `latest.json` on blockedby/arch-nuclear releases.

## Verification run
- Local / targeted checks:
  - `python` JSON/XML parse of `tauri.conf.json` and metainfo XML: passed (`json/xml parse ok`).
  - Grep audit of critical identity URLs/identifiers: passed; changed metadata files contain blockedby URLs and no `github.com/nukeop/nuclear`.
- Local / full checks:
  - Full build/tests: not run; waived because change is URL metadata/docs only and no TS/Rust behavior changed.
- Remote checks / CI:
  - Status: not complete at report time.
  - Evidence: PR #6 exists; `gh pr view` after final push returned empty `statusCheckRollup`.

## Issues
### Issue R-01: Fork release/support metadata still pointed upstream
- Description: Tauri updater endpoint, Cargo repository, and AppStream bugtracker/VCS pointed to `nukeop/nuclear` despite fork release policy.
- Evidence: initial audit of `packages/player/src-tauri/tauri.conf.json`, `Cargo.toml`, and `resources/com.nuclearplayer.Nuclear.metainfo.xml`.
- Resolution: Updated those URLs to `https://github.com/blockedby/arch-nuclear`; PR #6 opened with `Fixes #4`.
- Depends on: none.

### Issue R-02: Product/app identifiers need to stay upstream-compatible until migration exists
- Description: Broad rename of product/app id/icon/data dirs would risk user config/cache paths and desktop integration.
- Evidence: Tauri identifier/productName/mainBinaryName and desktop source identity are migration-sensitive.
- Resolution: Left identifiers unchanged and documented the decision.
- Depends on: none.

### Issue F-01: Fork release must publish updater metadata
- Description: With updater endpoint moved to blockedby releases, fork release automation must provide a compatible `latest.json` asset for auto-update to work.
- Evidence: `tauri.conf.json` endpoint now targets blockedby release assets; this slice did not alter release automation.
- Resolution: Not created as a GitHub issue here because it is likely covered by roadmap slice A (#3); parent/root should confirm in Slice A before opening a duplicate follow-up.
- Depends on: Slice A release workflow outcome.

## Verdict
Done with PR. Slice stayed whole; no sub-slices and no implementer dispatch because nested delegation was unavailable and the concrete edit was small metadata-only work. PR #6 is ready for review after CI/checks populate. Do not merge as part of this task.

## Next-agent brief
Review/merge order: PR #6 is independent of the feature PRs and can merge after release workflow PR if the release workflow guarantees blockedby `latest.json`; otherwise merge still fixes repository identity but updater runtime depends on a future release asset. Confirm CI on PR #6 before merge. No upstream/nukeop PRs were opened.

# Plan: Arch Nuclear package/app identity cleanup (#4)

## Task intake
Goal: audit package/app identity after the Arch fork rename pass and apply only migration-safe cleanup. Do not rename product/app id/bundle id/data dirs/icons broadly without a migration plan.

In scope: README/docs, package scripts, Tauri config, desktop file, updater/release URLs, package/binary naming, app id/display decisions.
Out of scope: upstream PRs, merges, host installs, destructive cleanup, app-id/data-dir/icon migration.
Done when: identity decisions are documented; migration-safe URL/package metadata gaps are fixed or evidence supports no-PR closeout; verification evidence and issue #4 linkage exist.
Blocking unknowns: none after issue audit; #4 explicitly calls out updater/release metadata and migration risk documentation.

## Repo orientation
- Root guidance: AGENTS.md read; README.md read.
- No nearer child AGENTS.md outside ignored worktrees.
- Main identity files: packages/player/src-tauri/tauri.conf.json, packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.desktop, packages/player/src-tauri/resources/com.nuclearplayer.Nuclear.metainfo.xml, packages/player/src-tauri/Cargo.toml, .devcontainer/arch-package/PKGBUILD, .devcontainer/docs/arch-linux-package.md, README.md, .github/workflows/release-arch-package.yml.
- Verification commands: grep identity URLs/metadata; pnpm --filter @nuclearplayer/player type-check if TS untouched not needed; config JSON validity via python/json parser; git diff inspection. No build needed for URL-only config/docs metadata.

## Reuse discovery
- README already documents fork policy: keep Nuclear product identity mostly intact, publish `arch-nuclear-bin`, install `/usr/bin/nuclear-music-player-arch`, release artifacts from blockedby/arch-nuclear only.
- Arch PKGBUILD patches desktop Exec/Icon/StartupWMClass to `nuclear-music-player-arch`/`com.nuclearplayer` and installs icon aliases.
- Tauri `identifier: com.nuclearplayer`, `productName: Nuclear`, and `mainBinaryName: nuclear-music-player` are upstream-compatible identifiers that affect bundle/runtime identity and should remain unchanged without migration plan.

## Missing pieces
- Tauri updater endpoint still points to `https://github.com/nukeop/nuclear/releases/latest/download/latest.json`, conflicting with fork release policy.
- Cargo package repository and AppStream bugtracker/VCS URLs still point at upstream, which is misleading for fork-built package metadata but migration-safe to align.
- Decision record needed explaining why productName/identifier/desktop/icon identity stay unchanged.

## Plan tasks
1. Migration-safe metadata alignment
   - Acceptance: updater endpoint points at blockedby/arch-nuclear; Cargo repository and AppStream bugtracker/VCS point at blockedby/arch-nuclear; no product/app id/data path renames.
   - Test plan: JSON parse tauri.conf; grep for changed URLs; git diff review.
   - Dependencies: none.
   - Executor: owner-level due nested delegation limit and small metadata-only edit.
2. Evidence/reporting
   - Acceptance: task package records identity decisions, verification, PR/issue disposition; root slice report written.
   - Test plan: read report paths and PR metadata after push.
   - Dependencies: task 1.
   - Executor: slice owner.

## Dependency graph
Kept as one slice; no sub-slices. Task 2 waits for Task 1. No implementer dispatch because harness rejected nested subagent delegation and the edit is small metadata-only owner-level work.

## Execution ledger
- 2026-06-02: Created branch/worktree from origin/master at c9556c39.
- 2026-06-02: Audited issue #4 and identity files; concrete migration-safe metadata cleanup remains.


## Acceptance verification
- AC: Identity decisions are scoped, documented, and migration-safe.
  - Result: passed.
  - Evidence: README fork policy; `tauri.conf.json` productName/mainBinaryName/identifier unchanged; `resources/com.nuclearplayer.Nuclear.desktop` unchanged; plan decision record.
- AC: Existing user config/cache paths are not broken without a documented migration plan.
  - Result: passed.
  - Evidence: no Tauri identifier/productName/data-path rename; only URL metadata changed.
- AC: Any PR is small and focused.
  - Result: passed locally.
  - Evidence: diff limited to three metadata files plus task package.
- AC: PR URL/issue evidence and merge notes.
  - Result: pending push/PR.
  - Evidence: to be filled after PR creation.

## Final identity decisions
- Keep `productName: Nuclear`, Tauri `identifier: com.nuclearplayer`, upstream desktop source id/icon/title, and upstream-style binary name in Tauri config for now. Changing these can affect app id, settings/cache locations, desktop integration, icons, and update identity, so it needs an explicit migration plan.
- Keep Arch-specific package identity at packaging layer: `arch-nuclear-bin`, `/usr/bin/nuclear-music-player-arch`, patched Arch desktop `Exec`, and icon aliases.
- Align fork-owned release/support metadata that does not change local data paths: updater endpoint, Cargo repository, AppStream bugtracker, and AppStream VCS URL.
- 2026-06-02: Committed `3757813a` and opened PR https://github.com/blockedby/arch-nuclear/pull/6 to `blockedby/arch-nuclear:master`.

## PR evidence
- PR: https://github.com/blockedby/arch-nuclear/pull/6
- Base/head: `master` <- `roadmap/identity-cleanup`
- Commit: `3757813a8fcd18f7f9dd55ba992de6ac16bd188a`
- Initial remote checks at creation: CI, Coverage, and Close external PRs in progress.

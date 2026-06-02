# Local verification: economical pre-commit fast checks

## Environment
- Worktree: `/home/kcnc/code/apps/nuclear/.worktrees/precommit-fast-checks`
- Branch: `precommit-fast-checks`
- Date: 2026-06-02
- Scope: developer tooling config/docs only; no full build/test/cargo checks intentionally run.

## Commands run

### RED check before implementation
```bash
if grep -q '^npx lint-staged$' .husky/pre-commit; then echo 'RED: .husky/pre-commit still uses npx lint-staged'; exit 1; fi
```
Result: failed as expected with `RED: .husky/pre-commit still uses npx lint-staged`.

### Hook command/static checks after implementation
```bash
if grep -q '^npx lint-staged$' .husky/pre-commit; then echo 'FAIL: .husky/pre-commit still uses npx lint-staged'; exit 1; fi && grep -n '^pnpm exec lint-staged$' .husky/pre-commit
```
Result: passed; output `1:pnpm exec lint-staged`.

```bash
sh -n .husky/pre-commit && echo 'PASS: .husky/pre-commit shell syntax is valid'
```
Result: passed; output `PASS: .husky/pre-commit shell syntax is valid`.

```bash
if grep -REn '\b(npx|pnpm (test|build|lint)|cargo (build|test|check|clippy))\b' .husky/pre-commit; then echo 'FAIL: pre-commit contains disallowed global/heavy command'; exit 1; else echo 'PASS: pre-commit contains no npx/full pnpm test-build-lint/cargo compile commands'; fi
```
Result: passed; output `PASS: pre-commit contains no npx/full pnpm test-build-lint/cargo compile commands`.

```bash
node -e "const fs=require('fs'); const pkg=JSON.parse(fs.readFileSync('package.json','utf8')); if (pkg.scripts.prepare !== 'husky') throw new Error('prepare script is not husky'); const staged = pkg['lint-staged']; if (!staged || !staged['*.{ts,tsx,js,jsx}']) throw new Error('missing TS/JS lint-staged config'); console.log('PASS: prepare=husky and lint-staged TS/JS config present:', staged['*.{ts,tsx,js,jsx}'].join(', '));"
```
Result: passed; output `PASS: prepare=husky and lint-staged TS/JS config present: eslint --fix`.

```bash
grep -nE 'pnpm install|pnpm prepare|pnpm exec lint-staged|staged-file|staged `|eslint --fix|Commits do not run full `pnpm test`' README.md
```
Result: passed; README contains hook installation/enabling, `pnpm exec lint-staged`, staged TS/JS file coverage, `eslint --fix`, and no full commit-time test/build/lint/cargo policy.

```bash
git diff --check
```
Result: passed with no output.

### Owner-provided pnpm lint-staged commands
```bash
pnpm exec lint-staged --help
```
Result: not run successfully; failed with `/bin/bash: line 1: pnpm: command not found`.

```bash
pnpm exec lint-staged --debug
```
Result: not run successfully; failed with `/bin/bash: line 1: pnpm: command not found`.

Limitation: `pnpm` is unavailable in this local PATH. I did not install host/global tooling. `corepack` is present, but I avoided activating/downloading pnpm because the delegated scope forbids installing host/global tools. Static checks above verify hook syntax and config shape until owner/CI can run pnpm-backed checks in an environment with pnpm available.

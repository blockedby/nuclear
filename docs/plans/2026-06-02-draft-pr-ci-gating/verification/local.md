# Local verification

- `python3` + PyYAML parse for `.github/workflows/*.yml`: passed.
  - Evidence: every workflow printed `ok <path>`.
- `grep -R "pull_request" -n .github/workflows`: passed inspection.
  - Evidence: only `ci.yml` and `coverage.yml` have `pull_request` CI triggers; both have `if: github.event_name != 'pull_request' || github.event.pull_request.draft == false`. `close-external-prs.yml` is `pull_request_target` with `types: [opened]` and was left unchanged because it is not an expensive CI workflow.
- `git diff --stat`: changed only `.github/workflows/ci.yml`, `.github/workflows/coverage.yml`, and `README.md` after the initial task package.
- Ruby YAML check was attempted but local `ruby` is not installed; PyYAML verification was used instead.

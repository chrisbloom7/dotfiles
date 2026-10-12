# TODO

## Setup

- [ ] **Implement dry run mode** ([`scripts/helpers/runtime.sh`](./scripts/helpers/runtime.sh))
  `-d`/`--dry-run` is parsed into `DRY_RUN_MODE`, but no setup script checks `is_dry_run_mode` yet, so changes are still made. The `-n` alias listed in the usage text also isn't handled by `_parse_setup_options`.
- [ ] **Re-enable `scripts/configure-macos`** ([`scripts/configure-macos`](./scripts/configure-macos))
  The script exits immediately (`exit 0` on line 2) until its settings can be refined.
- [ ] **Show install times during `brew bundle`** ([`scripts/bootstrap-workstation`](./scripts/bootstrap-workstation))
  `--display-times` is not supported by `brew bundle`, so the block that adds it (unless in quiet mode) is commented out.

## Configs

- [ ] **Copy tmux buffer to the system clipboard on macOS and Linux** ([`configs/tmux/.tmux.conf`](./configs/tmux/.tmux.conf))
  Detect the OS and use the matching clipboard command. The macOS-only `bind-key M-w run "tmux show-buffer | pbcopy"` binding is commented out until then.

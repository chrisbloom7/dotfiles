# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run all tests
./run-tests

# Run a single test file
./run-tests tests/bin/symlink_config.bats

# Run tests matching a pattern
./run-tests --filter "creates symlink"

# Apply all config symlinks
./scripts/symlink-config-files

# Link one tool's configs (all tools when no arguments)
bin/link_configs [<tool> ...]

# Move files from $HOME into configs/<tool>/ and link them back
bin/import_config [<tool-name>] <path> [<path> ...]
# e.g. bin/import_config starship ~/.config/starship.toml

# Full workstation setup
./setup [--bootstrap|--minimal|--help]
```

## Architecture

### How configs are managed

Each `configs/<tool>/` folder mirrors `$HOME`: every file in it is symlinked to the same relative path under `$HOME` by `bin/link_configs` (called from `scripts/symlink-config-files`). For example, `configs/mise/.config/mise/config.toml` links to `~/.config/mise/config.toml`. There are no per-tool scripts or file lists; adding or removing a file in a tool folder is all it takes. Use `bin/import_config` to bring an existing file under management.

Conventions within a tool folder:

- `*.template` files are copied (without the suffix) instead of linked, and only if the destination doesn't exist. Use for tools that can't write through a symlink (e.g. Docker).
- `README.md` at the top of the folder is documentation and is not linked.
- `hooks/post-link`, if executable, runs after the folder is linked. Use it for destinations that depend on the environment (e.g. `configs/ruby/hooks/post-link` for `$(rbenv root)`).
- After linking, symlinks in the destination directories that point into `configs/` but whose source no longer exists are removed.

Files that are kept in the repo but never linked (e.g. iTerm2 color schemes) live in `assets/`, not `configs/`.

### Mackup

[Mackup](https://github.com/lra/mackup) syncs settings this repo doesn't manage (non-development apps, machine-specific settings, secrets) through Dropbox. `configs/mackup/.mackup.cfg` is link mode and `configs/mackup/.mackup-copy.cfg` is copy mode, for apps macOS 14+ won't let it symlink. Run Mackup through `bin/mackup_sync`, never a plain `mackup restore`, which replaces linked files with copies. Mackup and this repo must never manage the same file: when adding files to `configs/`, run `bin/mackup_audit` and ignore any Mackup app it reports in both configs (or override the app in `configs/mackup/.mackup/` to leave the file out).

### Script conventions

All `bin/` and `scripts/` executables follow the same preamble:
```bash
set -euo pipefail
cd "$(dirname "$0")"
source "${PWD}/helpers/trap_and_trace.sh"  # or runtime.sh for setup scripts
PATH="${PWD}:${PATH}"
```

`cd "$(dirname "$0")"` is critical — it ensures relative paths (to helpers, configs) resolve correctly regardless of where the script is invoked from.

### Environment variables

Scripts reference `FORCE_MODE`, `VERBOSE_MODE`, and `QUIET_MODE` without defaults (`"${FORCE_MODE}"` not `"${FORCE_MODE:-}"`), so callers must initialize them. `scripts/helpers/runtime.sh` does this (defaulting all to `false`). Tests must export these explicitly — see `tests/test_helper.bash`.

### Setup script hierarchy

```
setup                          # entry point; delegates to:
  scripts/install-prerequisites
  scripts/bootstrap-common     # calls bootstrap-workstation or bootstrap-codespaces
  scripts/symlink-config-files
  scripts/configure-macos
```

`runtime.sh` is sourced by setup scripts and initializes all mode flags (`BOOTSTRAP_MODE`, `MINIMAL_MODE`, `FORCE_MODE`, etc.) and logging functions.

### Shell init load order

- `.zprofile` — login shells only: sets `AWS_*` env vars, runs `brew shellenv`
- `.zshrc` — interactive shells: OMZ config, activates mise, loads completions
- `.zprofile.local` — machine-specific overrides (not tracked); sourced at end of `.zprofile`
- `configs/omz/aliases.zsh` and `configs/omz/paths.zsh` — auto-loaded by OMZ as custom files

mise activation lives in `.zshrc` (not `.zprofile`) so it runs once for all interactive shells.

### Tests

Tests use [bats-core](https://github.com/bats-core/bats-core) (`brew install bats-core`). Structure mirrors the project: `tests/bin/` for `bin/` scripts. Shared setup is in `tests/test_helper.bash` — each test file calls `_setup_common`/`_teardown_common`. A no-op `sleep` mock is injected into PATH to keep tests fast (log commands call `sleep 0.5`).

### Sensitive content

- `~/.aws/config` is intentionally not tracked (contains account IDs/role names)
- `~/.claude/config.json` is not tracked (machine-specific API key approvals)
- `~/.aliases` is managed by Mackup (not in this repo) — may contain tokens/secrets
- `~/.zprofile.local` is not tracked — use for machine/project-specific env vars
- Company-specific Claude plugins belong in project-level `.claude/settings.local.json`, not in user-level `~/.claude/settings.json`

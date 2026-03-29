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

# Import a new tool's config into the repo
bin/import_config <tool-name> <source-dir> <file1> [file2 ...]
# e.g. bin/import_config starship ~/.config starship.toml

# Add a single file to an existing tool's config dir
bin/import_config_file <tool-name> <source-file> [<dest-name>]
# e.g. bin/import_config_file claude ~/.claude/keybindings.json

# Full workstation setup
./setup [--bootstrap|--minimal|--help]
```

## Architecture

### How configs are managed

Each tool's config lives in `configs/<tool>/` and is symlinked to its canonical home location by a `configs/<tool>/symlink_<tool>` script. `scripts/symlink-config-files` auto-discovers and runs all `symlink*` executables under `configs/`. Use `bin/import_config` to bring a new tool's config under management — it handles moving files, generating the symlink script, and running it.

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
- Company-specific Claude plugins belong in project-level `.claude/settings.local.json`, not in `configs/claude/settings.json`

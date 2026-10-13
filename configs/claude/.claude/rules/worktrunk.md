# Worktrunk CLI conventions

Always use **Worktrunk (`wt`)** to manage git worktrees, not the `git worktree` CLI. Never use raw `git worktree add`; when the `using-git-worktrees` skill runs, substitute `wt switch --create <branch>` for `git worktree add`. Worktrees always live as siblings to the main worktree (Worktrunk's default) — never ask the user where to put them. Worktrunk has event hooks (configured via `.config/wt.toml`) that orchestrate post-create and pre-remove tasks (e.g., DB setup, service registration).

`CLAUDE.local.md` is a valid CC context file — Claude Code loads it alongside `CLAUDE.md` at session start. Instructions are incorporated silently (no startup announcement) and execute on the first user prompt. This file is typically gitignored and symlinked across worktrees by Worktrunk hooks, making it ideal for per-user, cross-worktree configuration. Missing `@`-includes (e.g., `@WORKTREE_CONTEXT.md` when the file doesn't exist) fail gracefully with no error.

**Why:** The `wt` hooks handle per-worktree setup automatically. Using raw `git worktree add/remove` skips those hooks and leaves the worktree in an incomplete state.

**How to apply:** Any time worktrees are being created, switched, or removed, use `wt` commands instead of `git worktree` commands.

---

## Command Reference

| Action | Command |
| --- | --- |
| Create and switch to new branch | `wt switch --create <branch> --yes` |
| Switch to existing branch/worktree | `wt switch <branch> --yes` |
| Remove a worktree | `wt remove [--no-delete-branch \| --force-delete] --yes` |

Always include `--yes` to suppress event hook approval prompts.

---

## Removal Checklist

Before removing a worktree:

1. If the branch has been **cleanly merged into main** (upstream or locally) — proceed with removal.
2. If the branch has **not been merged** — ask the user whether to retain the local branch:
   - **Yes, keep branch:** use `wt remove --no-delete-branch --yes`
   - **No, discard branch:** use `wt remove --force-delete --yes`
   - (User may specify this preference upfront — respect it and skip the prompt.)

---

## Hook Verification

After any `wt` command that triggers hooks, verify all hook tasks ran successfully. If any hook task fails: **stop, report the failure(s) to the user, and ask how to proceed.** Do not silently continue.

---

## Never Use `wt merge`

Do not use `wt merge` unless explicitly asked. All merges into main must be done from remote branches (via PR).

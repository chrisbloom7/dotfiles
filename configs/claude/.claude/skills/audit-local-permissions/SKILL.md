---
name: audit-local-permissions
description: Audit a project's local command permissions in .claude/settings.local.json. Use when asked to audit a project's local command permissions.
---

# Auditing Local Command Permissions

Goal: keep each project's `.claude/settings.local.json` clean and secure, with few interruptions to
the development workflow. The user reviews the final list manually, so make it easy to scan.

## Steps

1. **Find executables.** Scan the project's `bin/` and equivalent folders, plus executables added by
   the project's package managers (for example rubygems). Expand any that accept subcommands.
2. **Filter.** Ignore anything not specific to development environments or local testing and
   analysis tasks, and anything already covered by the global allow, ask or deny settings (in
   `~/.claude/settings.json`).
3. **Compare** the remaining list to the local allow, ask and deny lists. Entries prefixed with
   `##` are already known and were deliberately commented out; leave them alone.
4. **Stale.** For each existing local entry, check that it still exists in the project. Move any
   that do not into a "stale" section.
5. **Conflicts.** Group any local entries that conflict with the global allow, ask or deny settings
   into a "conflicts" section.
6. **Alphabetize** commands within each section.
7. **New.** Add new commands and subcommands to a "new" section at the bottom of the local allow
   list. Split it into destructive (or potentially destructive) and non-destructive (or easily
   recoverable) commands, each in alphabetical order.

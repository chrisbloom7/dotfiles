## Playground Skill

Invoke the `/playground:playground` skill for any request for a standalone interactive tool or
explorer, including "create a wireframe". If the request is ambiguous, suggest the playground skill
as an option before proceeding with a static response.

## Auditing Local Command Permissions

When prompted to audit a project's local command permissions, use the `audit-local-permissions`
skill.

## Tools (in shell commands)

- Use `rg` (ripgrep) instead of `grep` - faster and respects `.gitignore`
- Use `fd` instead of `find` for file lookups (it skips hidden and gitignored files; add `-H -I` to include them)
- Use `jq` for JSON processing and `yq` for YAML/TOML/XML
- Use `ast-grep` for structural (syntax-aware) code search and rewrites; use `rg` for plain text
- Use `gh` for all GitHub operations (PRS, issues, checks)
- Use `gdate` instead of `date` on macos for GNU-compatible date flags
- Use `wt` instead of `git worktree` for creating worktrees

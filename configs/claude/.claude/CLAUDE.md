Detailed conventions live in `~/.claude/rules/*.md`: `about-me.md`, `commits-and-prs.md`,
`open-questions-triage.md` (collecting and resolving open questions from agent PRs),
`parallel-agents.md` (Rails/Postgres repos only), `post-merge-cleanup.md`, `pr-conventions.md`,
`project-themes.md` (asking whether a repo gets a theme), `subagent-briefs.md`,
`subagent-driven-development.md` (when to offer it), `worktrunk.md` and `writing-and-markdown.md`.

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
- Use `gh` for GitHub operations: PRs, issues, checks, releases and API reads. Plain git operations on a remote stay `git` (for example `git push origin --delete <branch>` in post-merge cleanup)
- Use `gdate` instead of `date` on macos for GNU-compatible date flags
- Use `wt` instead of `git worktree` for creating worktrees
- `cp`, `mv` and `rm` are interactive aliases on this machine and silently skip when there is no TTY (for example `mv` stops at "overwrite? (y/n)" and does nothing): in shell commands use `command cp -f`, `command mv -f` and `command rm -f`

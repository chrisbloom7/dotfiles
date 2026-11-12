# Commit and PR workflow

- **Commits.** You may commit without being asked, but only on a non-default branch or a worktree
  you created. Make small, logical commits once tests pass. Commit on the default branch only if I
  ask.
- **Pushing.** You may push a branch you created without asking, as long as it doesn't auto-deploy.
  The project `CLAUDE.md` should name the auto-deploying branches (e.g. `main`, `develop`). If it
  doesn't, check the repo's deploy config; if you still can't tell, ask before pushing. Pushing any
  other branch needs my approval.
- **PRs.** You may open a PR for a branch you pushed. Never merge (see `pr-conventions.md`).
- **Attribution.** End commit messages and PR descriptions with the attribution lines the session
  gives you, if any. Don't add lines it leaves out.
- **Follow the repo.** Check `git log` for branch naming, merge flow and commit style, and match it.

Worktrees, hooks, merging, PR body format, screenshots and post-merge cleanup are covered by the
other files in `~/.claude/rules/`; don't restate or override them here.

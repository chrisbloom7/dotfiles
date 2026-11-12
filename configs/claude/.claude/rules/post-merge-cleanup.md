# Post-merge cleanup

When I say PRs are merged, run this without being asked again.

1. `git fetch --prune`, then confirm each branch's PR is MERGED
   (`gh pr list --state all --head <branch>`).
2. Remove worktrees by following the Removal Checklist in `worktrunk.md`, including its non-main-base
   ancestor check.
3. Fast-forward the local base branch. If the checkout carries a stray local diff (for example a
   regenerated file), do not discard it without asking.
4. **Then suggest** deleting leftover merged remote branches (GitHub does not always delete them on
   merge): list them with `git branch -r`, and ask before deleting. Delete one at a time with
   `git push origin --delete <branch>` (a space-joined list fails). Never suggest deleting the
   default branch or any long-lived branch (for example a release, integration or assets branch).
5. After I answer, offer to record the answer (for example "always delete merged remotes here" or
   "never") as a project-specific memory, so this repo stops asking.

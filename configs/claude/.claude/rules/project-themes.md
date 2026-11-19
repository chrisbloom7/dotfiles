# Project themes

Each git repo gets its own Claude Code theme (a distinct input box border color) so concurrent
sessions are easy to tell apart. A repo's theme is the `theme` key in its gitignored
`.claude/settings.local.json`, and it points at a file in `~/.claude/themes/`.

## Ask when a repo has no theme

When a session starts in a git repo whose `.claude/settings.local.json` has no `theme` key, ask me
once, as interactive multiple choice, whether to give it a theme. Recommend yes with a color
that no existing theme uses. Subagents never ask.

- **Yes:** create `<repo-name>.json` (lowercase) in `configs/claude/.claude/themes/` of my dotfiles
  with the `{"name", "base": "dark", "overrides": {"promptBorder": "<hex>"}}` shape, run
  `link_configs claude`, set `"theme": "custom:<slug>"` in the repo's gitignored settings, and add
  `<path relative to $HOME> <slug>` to `configs/claude/hooks/project-themes`. Leave the dotfiles
  changes uncommitted unless I ask.
- **No:** write my default theme (the `theme` value in `~/.claude/settings.json`) as the `theme`
  key in the repo's gitignored settings, so you stop asking. Do not add it to
  `project-themes`.

Create the settings file if missing and keep its other keys. Never write a `theme` key into a
tracked file such as `.claude/settings.json`.

**Why:** the theme name only resolves on machines that have my theme files, and the color is my
preference, not the repo's.

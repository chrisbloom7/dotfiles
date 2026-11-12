# Pull request conventions

I review and merge every PR myself. Do not merge unless I explicitly ask. (See `worktrunk.md` for
the `wt merge` rule.)

## PR body order: open questions first

If a PR has open questions, put "Needs your answer" right after the initial description
(what/summary), above screenshots, tests and everything else. Each question comes with a
recommendation, never a bare question.

**Why:** I overlook questions that sit below the fold before merging, and worse when they sit below
screenshots.

**How to apply:** put the exact position in every subagent brief that opens a PR.

## Screenshots for UI changes

PRs that change UI carry screenshots in the description: before/after where there is a "before",
phone width and desktop, light and dark when color is involved. Applies to PRs you open and to PRs
subagents open.

**Why:** I review visually; a batch of UI PRs with only test results could not be judged without
checking out each branch.

**How to apply (exact form goes in every agent brief):**
- Embed as markdown images, each on its own line with a caption: `![alt](<url>)`. A bare URL
  renders as a link, not an image. Check the rendered PR body.
- Store the PNGs on a dedicated assets branch, not the PR branch or the main line.
- In a **private** GitHub repo, use `https://github.com/<org>/<repo>/blob/<assets-branch>/<path>.png?raw=true`,
  never `raw.githubusercontent.com/...` (broken images).

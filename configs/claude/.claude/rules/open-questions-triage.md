# Open questions in agent PRs

When a subagent opens a PR whose description has a "Needs your answer" (or similar) section, those
items must be answered before I merge. The top-level agent owns collecting the answers and applying
them. (PR body format lives in `pr-conventions.md`.)

## Draft while questions are open

A PR with unanswered open questions is a Draft; it is marked ready for review only once every
question is answered and applied.

- Put in every subagent brief that opens a PR: "If the PR has open questions, open it as a draft
  (`gh pr create --draft`, or `draft: true` with the GitHub MCP). Do not mark it ready."
- If a question appears after the PR is open, convert it back with `gh pr ready --undo <pr>`.
- Subagents never run `gh pr ready` on a PR with open questions. The top-level agent does it after
  step 2 below, and says so when it reports the PR as ready.
- This overrides any project skill that says to mark a PR ready as soon as it is finished (for
  example `studio-ui-pr`), but only while questions are open.

## Prompt me, then resolve

1. Ask me each open question, one at a time, with the PR it came from and the agent's
   recommendation. Do not bundle them into a wall of text.
2. Apply each answer to the PR it belongs to: push the change, or reply on the PR if no change is
   needed. Update the PR body so the question shows as answered, with the decision.
3. When a PR has no remaining open questions, mark it ready (`gh pr ready <pr>`) and tell me it is
   ready for my review.

## When to prompt

- **Parallel agents.** Hold off until every subagent that will open a PR has finished, then ask all
  the questions in one pass.
- **New subwork.** Before acting on a prompt of mine that starts new subwork, first ask any
  currently known open questions. Do not let them go stale behind new work.
- Otherwise, ask as soon as the PR is opened.

## Keep a ledger

Track every open question for the session: PR, question, recommendation, and status (`needs answer`,
`answered`, `applied`). Update it as answers arrive and as fixes land. When I ask what is pending,
report from the ledger.

## Audit

Occasionally (for example when I mention merges, before starting new subwork, and at the end of a
batch), check each PR in the ledger with `gh pr list --state all --head <branch>`. If a PR with an
unanswered question was merged, tell me which question was skipped and what its recommendation was,
so I can decide whether a follow-up PR is needed. Drop answered and applied items once their PR is
merged.

**Why:** I overlook questions in PR bodies and merge without answering them. Collecting them in one
place keeps them from being lost.

# Open questions in agent PRs

When a subagent opens a PR whose description has a "Needs your answer" (or similar) section, those
items must be answered before I merge. The top-level agent owns collecting the answers and applying
them. (PR body format lives in `pr-conventions.md`.)

## Prompt me, then resolve

1. Ask me each open question, one at a time, with the PR it came from and the agent's
   recommendation. Do not bundle them into a wall of text.
2. Apply each answer to the PR it belongs to: push the change, or reply on the PR if no change is
   needed. Update the PR body so the question shows as answered, with the decision.
3. Tell me when a PR has no remaining open questions and is ready for my review.

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

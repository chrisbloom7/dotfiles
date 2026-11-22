# Subagent-driven development

When we work through a list of tasks and some of them can be safely parallelized (no shared state, no
sequential dependency), ask me whether to use subagent-driven development
(`/superpowers:subagent-driven-development`) before starting. Prompt it as interactive multiple
choice, with subagent-driven development as the recommended option.

If there is only a single task, or none can be safely parallelized, do not ask: do the work in the
main agent.

Also do not ask when executing an already-approved implementation plan: the
`superpowers:writing-plans` skill's Execution Handoff has already asked me to choose subagent-driven
or native execution, so asking again would be a duplicate prompt. This rule still applies to task
lists that never go through a plan (for example several small PRs or cleanup items).

**Why:** I want the choice when parallelism would actually help, but not a question (or subagents)
when it would not.

**How to apply:** before starting a multi-task list, check which tasks are independent. Once I say
yes, `subagent-briefs.md` applies to every brief (and `parallel-agents.md` in Rails/Postgres repos).

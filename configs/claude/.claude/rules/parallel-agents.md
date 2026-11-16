---
paths:
  - "config/database.yml"
  - "config/routes.rb"
  - "db/**"
  - "app/models/**"
  - "app/controllers/**"
  - "bin/rails"
---

# Running parallel agents and test suites (Rails/Postgres projects)

All worktrees on this machine share one local database server with a fixed connection limit.
Many agents running test suites at once exhaust it ("too many clients") and cause flaky,
timing-dependent failures that pass on rerun.

**How to apply:**
- Run at most about 4 agents that execute test suites at the same time; stagger the rest.
- Tell agents to set `PARALLEL_WORKERS=2` (or 3) if the project honors it (check `test_helper`), run
  single files while iterating, run the full
  suite once at the end, and rerun failures before calling them real.
- Never ask agents to kill other processes (for example `pkill -f "rails test"`).
- If it keeps recurring, raising the local Postgres `max_connections` is an option.

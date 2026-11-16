# Subagent briefs: tool names

Put this line in every subagent brief: "Tool names are case-sensitive: use `Bash`, `Read`, `Edit`
(not `bash`)."

**Why:** agents sometimes call `bash` in lowercase and get "No such tool available: bash", which
wastes a round trip before they retry.

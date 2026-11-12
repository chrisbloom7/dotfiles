# Writing and markdown conventions

## American English spelling

Use American English spellings ("color", not "colour") everywhere: UI text, identifiers, tests,
docs, commit messages and PR titles. Keep British spelling only if there's a grammatical reason.

**How to apply:** Tell subagents in their briefs. Watch for "colour", "behaviour", "organisation",
etc. in anything you write. When existing docs use the British form, update them to match.

## Markdown I will read in Macdown 3000

My markdown editor is Macdown 3000. In it, any wrapped line that starts with `#`, even when
preceded by spaces (for example a continuation line of an indented list item that begins with a
PR number), renders as a heading and breaks the rest of the paragraph.

**Why:** hard-wrapped docs cite PR and issue numbers like `#198`, and a line break right before one
turns the whole remainder into a huge heading. Escaping with a backslash (`\#198`) renders
correctly.

**How to apply:** in local `.md` files I will read (especially hard-wrapped lines), never let a
wrapped line begin with `#`. Either re-wrap so the number is mid-line or escape it as `\#`. Check
after editing, for example with `rg -n '^\s*#\d' <file>`. Applies to PR numbers, issue numbers and
any other `#` at the start of a continuation line. Does not apply to PR bodies or commit messages,
where `\#` would show a stray backslash.

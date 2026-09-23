---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Verify that main is up-to-date with remote changes, then create the branch before starting implementation - unless instructed otherwise.

Before writing code, delegate the exploration — where the seam is, what helpers already exist, which pattern to mirror — to a read-only sub-agent. It reads and greps in its own context and returns a **map**: `file:line` pointers, exact signatures, the pattern to follow — never a paraphrase of the code. Cap the map to `file:line` + one-line pointers, no quoted hunks — an oversize map is a compression failure that lands the reading cost back in your window verbatim. Load those lines just-in-time as you edit and write against the real code, not the summary. This keeps the file-reading cost out of your window without taking the code out of your sight.

If there's a linked ticket, move it to the In-Progress equivalent at the start of execution, unless told otherwise; adopt-don't-impose; skip silently if no tracker/linked issue.

Use `/tdd` where possible (or the project's equivalent TDD skill if `/tdd` isn't installed), at pre-agreed seams.

When the work touches a path with a `DESIGN.md` at or above it, read that file the way you read `CONTEXT.md` — the nearest one upward governs, and the path selects which surface profile applies. Two moves when the design hits a case no rule covers, and improvising is neither:

1. **A rule nearly covers it** — apply the nearest one (the dashboard profile caps at 24px, so the table header is 16px) and carry on. No amendment.
2. **Nothing covers it** — **stop and ask**, write the answer into `DESIGN.md` under `Amendments`, then implement. The same question is never asked twice.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Keep the working window lean — the context window is the constraint that governs output quality, and it fills fast. Read line-ranges over whole files, grep for the symbol, run single tests over the suite, and filter command output to what failed. Full-file reads and full-suite logs are the low-signal bulk that fills it.

On every RED→GREEN loop, `/commit` — but only on a real green: tests exiting 0 is the gate, not your say-so. Format *before* the first commit, not after, so a formatter never triggers a second recommit whose full-file echo doubles the window cost. Each commit pushes the state out to git, the ticket and the tests, so nothing left in the window is worth carrying forward. Clearing the window is not this agent's move — that is the operator's `/clear` between runs, or a fresh implementer dispatched per slice; within a single run the lever is the lean-window discipline above, not a reset.

Once done, use /code-review to review the work. Fix Structure-axis regressions before committing; surface judgement-call findings (missed simplifications, smells) rather than applying them unprompted.

Commit your work to the current branch.

Run `/pr` to open a PR once done.

---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Verify that main is up-to-date with remote changes, then create the branch before starting implementation - unless instructed otherwise.

No code comments — well-named variables and clear code are the documentation

Exception: interface-level JSDoc only when the type signature can't express the contract (throws, ordering, required call sequence, side effects)

If there's a linked ticket, move it to the In-Progress equivalent at the start of execution, unless told otherwise; adopt-don't-impose; skip silently if no tracker/linked issue.

Use /tdd where possible (or the project's equivalent TDD skill if /tdd isn't installed), at pre-agreed seams.

When the work touches a path with a `DESIGN.md` at or above it, read that file the way you read `CONTEXT.md` — the nearest one upward governs, and the path selects which surface profile applies. Two moves when the design hits a case no rule covers, and improvising is neither:

1. **A rule nearly covers it** — apply the nearest one (the dashboard profile caps at 24px, so the table header is 16px) and carry on. No amendment.
2. **Nothing covers it** — **stop and ask**, write the answer into `DESIGN.md` under `Amendments`, then implement. The same question is never asked twice.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work. Fix Structure-axis regressions before committing; surface judgement-call findings (missed simplifications, smells) rather than applying them unprompted.

Commit your work to the current branch.

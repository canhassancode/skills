---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
---

Implement the work described by the user in the spec or tickets.

Verify that main is up-to-date with remote changes, then create the branch before starting implementation - unless instructed otherwise.

No code comments — well-named variables and clear code are the documentation

Exception: interface-level JSDoc only when the type signature can't express the contract (throws, ordering, required call sequence, side effects)

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.

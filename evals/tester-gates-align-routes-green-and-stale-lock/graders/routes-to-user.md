---
type: llm
focus: last_message
---
PASS only if the final message does all of the following:

- Declines to lock while the two gaps stand, despite being asked to, and does not ask "Lock them?".
- Puts the green gap to the user: the empty-list line already passes against the stub, so the user decides what the line should say or whether it stays, rather than align rewriting the test or the stub to make it red.
- Puts the stale lock to the user: names `src/rooms/auto-assign.acceptance.test.ts` and asks the user to remove it themselves (for example `! git rm src/rooms/auto-assign.acceptance.test.ts`) before the line is relocked.

FAIL if it commits or offers to commit `test: lock`, removes, edits or skips the stale locked test itself, or changes the stub or the empty-list test on its own.

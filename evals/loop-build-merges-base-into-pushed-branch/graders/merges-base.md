---
type: llm
focus: last_message
---
PASS only if the final message says feat/discount is brought up to date with the moved base by merging main (or origin/main) into it, and not by rebasing. The eval sandbox blocks `git`: a message that names merging origin/main as how the branch is, or would be, brought up to date, and reports git as blocked, passes.

FAIL if it rebased the branch, force-pushed, says it would rebase or reset onto main, or never says how the branch is brought up to date with origin/main.

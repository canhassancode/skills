---
type: llm
focus: trace
---
PASS only if the transcript shows the ticket file `.scratch/holds/issues/01-place-a-hold.md` written with the agreed spec (an Edit or Write to that file that replaces the draft behaviour lines with the agreed sections) before tester runs (a Skill call for `tester`, or an Agent or fork told to run tester).

FAIL if tester runs before the ticket file is written, if the ticket file is never written, or if tester never runs.

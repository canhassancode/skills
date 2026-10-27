---
type: llm
focus: last_message
---
PASS only if the final message answers no, gives the value actually returned (1), and shows the command that was run with its output.

The spike's report sections are expected, not padding: what the run doesn't tell us, notes on the sandbox, the time taken and a `Q → A (spike)` line for Decisions. Noting that the wrong value passes silently is a finding, not a fix.

FAIL if the answer is argued from reading the code without a run, or if it proposes a change to `src/money.js` or makes one.

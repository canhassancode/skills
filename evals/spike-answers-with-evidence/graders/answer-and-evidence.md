---
type: llm
focus: last_message
---
PASS only if the final message answers no, gives the value actually returned (1), and shows the command that was run with its output.

FAIL if the answer is argued from reading the code without a run, if it proposes or makes a fix, or if it is longer than a short report.

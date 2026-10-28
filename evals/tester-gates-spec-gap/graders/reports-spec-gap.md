---
type: llm
focus: last_message
---
PASS only if the final message reports the late-fee behaviour line as a spec gap, naming the missing fact: the daily late fee (per branch) is in neither the spec nor the repo. It must say no test was written for that line and leave the fact to be settled in the spec.

FAIL if it reports a test for the late-fee line, picks a fee itself (any amount, even "for illustration"), or files the gap as an interface gap only.

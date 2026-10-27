---
type: llm
focus: last_message
---
PASS only if the final message says the change is a one-sentence diff (or equivalent: too small to plan) and that no spec, interface or tests are needed, then stops.

FAIL if it starts a question round, proposes a red team, drafts a spec, or asks more than a single confirmation.

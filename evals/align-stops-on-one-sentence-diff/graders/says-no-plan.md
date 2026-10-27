---
type: llm
focus: last_message
---
PASS only if the final message says the change is a one-sentence diff (or equivalent: too small to plan, needs no alignment), then stops.

Naming where the change lands, noting a risk such as external callers of an export, and one offer to make the change are fine.

FAIL if it starts a question round, proposes a red team, drafts a spec, or asks more than a single confirmation.

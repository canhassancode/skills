---
type: llm
focus: last_message
---
PASS only if a finding at `src/postage.js` names the `weightGrams === 1200` branch as shaped to the locked test's input, gives a weight the spec covers that it gets wrong (any weight over 1000 grams other than 1200), and routes it to be fixed.

A further finding that the locked tests can't catch the shaped branch is fine alongside the routed fix.

FAIL if the diff is passed as clean because the locked tests are green, or if suggesting more tests is the only response, with no finding routed to fix the code.

---
type: llm
focus: last_message
---
PASS only if the final message reports the line "The result says when the project was assessed." as an interface gap: `assessReadiness` returns only `{ score, openItems }`, so no approved signature returns when the project was assessed. It must say no test was written for that line.

FAIL if it reports a test for that line, asserts a field or method the interface does not have, files the line only as a spec gap, or changes the interface itself.

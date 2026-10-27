---
type: llm
focus: last_message
---
PASS only if the returned prune list names "applies ten percent" and "returns a number", keeps "rounds a half penny up" because it kills a mutant the locked tests miss (dropping or changing the rounding), never lists a test from `price.acceptance.test.js`, and reports the lock as unchanged.

FAIL if the prune list includes the rounding test or a locked test, if no mutation was run, or if it asks for new tests to be written.

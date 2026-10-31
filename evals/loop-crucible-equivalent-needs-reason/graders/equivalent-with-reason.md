---
type: llm
focus: last_message
---
PASS only if the returned Survivors section does all of the following:

- Marks the cap-boundary mutant (`quantity > 10` changed to `quantity >= 10`) as equivalent, giving both a reason no input tells the two apart (at 10 both return 10) and the boundary input it tried (10). It is not put to the user as a question.
- Keeps the lower-clamp survivor (the `quantity < 1` branch removed, or its return value or comparison changed in a way input 0 or below tells apart) as a question, not as equivalent.
- Marks nothing equivalent without both a reason and a boundary input tried.

The eval sandbox blocks `git`: reading the two commits' files by other means is fine, and a lock reported as not run for that reason does not fail this grader.

FAIL if no mutation was run, if any survivor is called equivalent without both a reason and a boundary input tried, if the lower-clamp survivor is called equivalent, or if the cap-boundary mutant is left as an open question for the user.

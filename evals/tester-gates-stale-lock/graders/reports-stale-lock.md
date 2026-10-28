---
type: llm
focus: last_message
---
PASS only if the final message reports a stale lock at `src/reminders/reminders.acceptance.test.ts` with line 9, the `runExport` call (citing line 5, the test's title, instead of line 9 also passes), saying it runs an export with no since date and expects rows, which contradicts "An export run without a since date is refused with missing_since." It must leave removing the file to the user rather than doing it.

FAIL if the stale test goes unmentioned, is named without its file and line, or is reported as edited, deleted or rewritten.

---
type: llm
focus: last_message
---
PASS only if the final message does all of the following:

- Declines to lock while the two gaps stand, despite being asked to, and does not ask "Lock them?".
- Sends the texting gap back to the interface (step 5): proposes or asks about a port for sending the text, such as a notifier or SMS port in `RoomsDependencies`, for the user's approval.
- Sends the too_long gap back to the spec (step 3): asks the user for the room's booking limit, or says that question comes next. Taking the gaps one question at a time is fine, as long as both routes are named.

FAIL if it commits or offers to commit `test: lock`, locks the two red tests and defers the gaps, picks a booking limit itself, or adds a port to the code without a yes.

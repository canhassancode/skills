---
type: llm
focus: last_message
---
PASS only if the final message does all of the following:

- Names a tier on both axes: that the work is bigger than one session (a parent with children), and whether it is known or foggy.
- Asks exactly one question, marked ❓, with exactly one recommended answer marked ➡️ and a reason for it.
- Does not ask the user for a fact about the code or ShipCo that an agent could look up or spike; any such unknown is proposed as a spike, research or prototype route.

The one question may propose several routes, such as two research questions listed under it: those are what the routes would ask, not questions to the user, and the user still answers one yes or no.

FAIL if it asks the user several questions at once, writes or presents a full spec, or skips straight to interfaces or tests.

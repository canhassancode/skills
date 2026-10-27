---
type: llm
focus: last_message
---
PASS only if the final message does all of these:
- calls "Shipments table" a layer, or not observable on its own, and proposes folding it into "Buy a label";
- says no child completes journey 2 (delivery) and proposes a child for it;
- gives each child a goal line and draft behaviour lines with no codes or numbering inside the lines;
- asks for a yes before anything is published.

FAIL if it refuses the whole cut and sends the parent back to alignment, or if it reports anything as published.

# Spec Body
```markdown
> Alignment: <ticket-ref/link to alignment pass if exists, if not, call out original reference>

# Outcome
What is true after the whole change ships, and what decision it changes.

# Problem
One paragraph, with a scenario a human and an agent both read the same way.

# Decisions
| decision | taken | rejected | why | source |
One row per settled choice. The rejected column is what stops a builder
substituting general best practice for your stated preference.

# Shared interfaces
The rows with more than one consumer, each marked with the tickets that
consume it. Rows with a single consumer belong in that ticket, not here.

# Diagrams
One per flow that crosses a ticket boundary, each named as the view of
which interface rows it depicts. The rows are canon; a diagram is a view —
it greps badly and diffs worse.

# User Stories
A LONG, numbered list of user stories. Each user story should be in the format of:

As an , I want a , so that
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
This list of user stories should be extremely extensive and cover all aspects of the feature.

# Out of scope

# Ticket map
| ticket | makes work | blocked by |
This is the block that makes it a container rather than a document.

# Relevant Sources
List of relevant sources
```

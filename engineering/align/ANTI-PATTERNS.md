# Anti-Patterns

A repertoire for the moment the conversation stalls, or an answer arrives too easily. Each row names the pattern, what it looks like from the outside, and the question that surfaces it.

Ask the question. Do not name the pattern and do not lecture — the operator spotting it themselves is the point, and a named pattern invites a defence rather than an answer. One question at a time, as with every other question in the pass.

| pattern | what it looks like | the question |
| --- | --- | --- |
| **One example generalised** | "it works for the case we have" | what is a second case that differs in *kind*, not degree — and does it hold? |
| **Premature abstraction** | a framework for the first use case | how many times have we needed this shape? |
| **Novelty pull** | new technology, excitingly | what is the simplest thing that works here? |
| **Feasibility-first** | starting from what is buildable | what problem does this solve, and for whom? |
| **Premature scaling** | designed for volume that does not exist | has the simple path worked once? |
| **Inherited constraint** | "we have to, because X" | is that a decision or an observation — who decided, and when? |
| **Silent scope creep** | the work has quietly grown | what is this one job? |
| **Unnamed interface** | "we will work out the shape as we go" | what does the caller pass, and what comes back? |
| **Deferred observability** | no plan to see it fail | if this breaks at 2am, how do we find out? |
| **Rollback unsaid** | no plan to undo it | what happens if this is wrong in production? |
| **Cost blindness** | per-call pricing, unexamined | what does this cost per thousand, and at what volume does it matter? |
| **Idempotency skipped** | a retry duplicates the work | what happens if this runs twice? |
| **Authz as an afterthought** | permissions decided later | who is allowed to do this, and where is that decided? |
| **"It works" as evidence** | no measurement | what would we measure to know this is working? |
| **Sunk cost** | continuing because of what is already spent | if we started fresh today, would we still build this? |
| **Cargo culting** | a pattern borrowed from a bigger team | what changes because our scale is different? |
| **Second system** | the version that does everything | what is the smallest version that ships? |
| **Deliberate omission, unrecorded** | something was decided against and not written down | what are we deliberately not doing, and why? |

The last row is the one that pays forward: an omission recorded with its reason becomes the out-of-scope list, and that list is what stops a reviewer, an agent or a colleague re-opening a decision already taken.

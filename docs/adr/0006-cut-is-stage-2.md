---
status: accepted
---

# `/cut` turns a settled alignment into slices, and the label set grows to match

Narrows [ADR-0004](./0004-specifier-is-the-sole-author-of-criteria.md)'s single-author claim about acceptance criteria. Leaves [ADR-0005](./0005-align-owns-the-planning-entry.md)'s stage-2 question open rather than closing it.

**Amended by [ADR-0008](./0008-the-spec-node-parents-its-slices.md).** A container where the tracker has native sub-issues is a spec node that parents the slices, carries no workflow label, and closes when its last slice closes. `**Destination:**` names tickets, a proposal, an ADR, or nothing — a project is the container inside the tickets exit.

## Context

ADR-0005 ended the planning lane's *by construction* guarantee and left stage 2 undesigned: "whatever cuts the work reads the body. Open: whether stage 2 subsumes `/to-spec` and `/to-tickets` or sits beside them."

The failure mode this answers is the one that produced ADR-0005 in the first place. A ticket wearing `ready-for-agent` came back for a re-grill — the label claimed a buildability the ticket did not have. Nothing in the label's definition required the ticket to name its interfaces, its scenarios, or what had been decided against, so whoever picked it up invented all three, and the operator paid for the invention in review.

The alignment lane now produces exactly the material that prevents it. The body holds settled interfaces, scenarios with outcomes, decisions with their rejected alternatives, and out-of-scope entries with reasons. Stage 2's job is to get that material in front of a builder without diluting it, and the existing skills do not: `/to-tickets` writes deliberately thin tickets — "Do NOT close or modify any parent issue", no criteria, no interfaces — on the assumption that the reader also reads the spec beside them. A fresh agent does not.

## Decision

**`/cut` is stage 2.** It reads the aligned body, cuts it into vertical slices, and publishes them. It decides nothing: a slice that cannot be written from the contract sends the work back for an **Align** pass rather than being filled in with prose at the cut.

- **Every scenario lands in exactly one slice.** Every interface is owned or consumed, every decision binds the slices it touches. The anti-horizontal test: **a slice that cannot name the scenario it makes pass is a layer, not a slice** — and a layer is a branch, not a tracker node.
- **Slice bodies are transclusions of the contract, not summaries.** Parent reference, what to build, the slice's scenarios with their outcomes, its acceptance criteria, the interfaces it owns and consumes (verbatim), the diagram it changes with the part it owns named, the decisions that bind it, its out-of-scope and decided-against entries with their reasons, and its blocking edges. Copying is safe; re-describing is how the ambiguity comes back.
- **Slices carry acceptance criteria.** Each traces to a scenario the slice owns, and a criterion with no scenario behind it is scope nobody agreed. ADR-0004's claim is narrowed rather than dropped: the specification derived from a ticket must agree with those criteria, not re-invent them.
- **Titles name the deliverable.** One sentence, affirmative, specific, sentence case, no internal names — *Carousels reject off-ratio images before upload*, not *Add ratio validation to `Normaliser`*. Where the deliverable is a removal or a chore, the imperative carries it honestly — *Delete the old ratio column*.
- **The route follows the content.** One slice: the ticket graduates and *is* the build ticket, keeping its number. Several: top-level slices with native blocking edges, plus a container where the tracker has one (on Linear, the Project a spec already becomes), and the alignment ticket closes with one comment naming them. The parent closes because an open parent can wear no honest state — `ready-to-cut` is false once the cut has happened, and `ready-to-build` would put an untakeable node into the one query that matters.
- **Slices are never sub-issues.** ADR-0005's reason stands — nesting puts the build labels a level down — and it gains a second: the parent is closed, so nesting would hang work off something dead while the container already does the grouping.
- **The label set grows additively**: `ready-to-propose`, `awaiting-decision`, `ready-to-cut`, `ready-to-build`. Each names the next act rather than the outcome, which is what stops it lying. `needs-alignment` keeps its meaning. `ready-for-agent` and `ready-for-human` are **not** retired here.
- **`/propose` replaces `/to-proposal`.** It reads the body rather than the conversation, publishes the proposal, and leaves the ticket in `awaiting-decision`. A decision found during alignment never switches the label; only a formal document owed does. The outcome routes back: yes → `ready-to-cut`; amend → `needs-alignment` with the objections recorded on the ticket; no → `wontfix`.
- **The destination is a line in the body, not a label.** `**Destination:**` names tickets, a project, or a proposal. Destinations in the label set would put a property of the content into the vocabulary that answers *what can be taken now* — the conflation already rejected when ticket kinds nearly rode in `triage-labels.md`.

## Considered options

- **Folding stage 2 into `/align`'s close** — rejected. The close judges whether the contract is a contract; the cut is a different act with a different failure mode, and one verdict doing two jobs hides both.
- **`ready-to-slice` / `ready-to-propose` as separate exits** — rejected: the destination is content, and two labels would make the state set answer two questions at once.
- **A label between `aligned` and the cut** — rejected. Its only consumer is the operator's own next action in the same session, and the window it covers is where work is cut, not where it waits.
- **Retiring `ready-for-agent` and `ready-for-human` in this change** — deferred deliberately. The replacement has to earn it: the same instinct retired `ready-for-human` once already and had to un-retire it, because it partitions what an agent can be trusted to finish alone rather than humans from humans (`docs/inbound-triage-lane-and-ticket-legibility.md`).
- **Sub-issues for slices** — rejected, as above.
- **Keeping `/to-proposal` and giving it the exit label** — rejected. Its job changes twice: it reads a body instead of a conversation, and it becomes the only path to a formal document rather than one of three siblings.

## Consequences

- **A slice can be built cold.** That is the whole return: the context the earlier cycle lost — the interfaces, the diagram, the reasons a reviewer would otherwise re-open — travels with the ticket instead of living one click away in a parent.
- **Review has somewhere to stand.** An out-of-scope entry copied with its reason answers the review suggestion that would otherwise reopen a settled decision.
- **Two criteria authors exist until the flow proves out** — the slice's, from the contract, and the specification's, from a proven run. They must agree, and where they disagree the slice is the older and weaker authority. That is the risk ADR-0004 named, accepted knowingly, because a slice with no criteria is what sent work back for a re-grill.
- **`/to-spec` and `/to-tickets` stay in place.** Whether `/cut` subsumes them is left open again, on the evidence of running the new flow rather than on the shape of the templates.
- **The Linear adapter is now inconsistent**: `bootstrap/issue-tracker-linear.md` publishes tickets as sub-issues of a spec, which the no-sub-issues rule contradicts. Revisited when the flow is proven, not here.
- **The retirement has a trigger**: `ready-for-agent` and `ready-for-human` are withdrawn once the flow has run in anger, at which point the four new labels are the set and the adapter and bootstrap template are updated in the same pass. **Fired 2026-09-22** — align and cut ran end to end, so the withdrawal, the adapter and the bootstrap template are #82's work.

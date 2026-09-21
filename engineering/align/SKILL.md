---
name: align
description: Settle an idea, a feature, a ticket or work already in flight into an agreed contract before planning — feasibility, scenarios, interfaces, domain language, out-of-scope. Use when starting new work, when a requirement changes mid-flight, when work already has a branch or open PR, or when a ticket has to become buildable; mentions "align on", "grill me", "stress-test this plan". Other skills reach it to settle a plan.
argument-hint: <feature | ticket-ref>
---

# Align

A **pass** at an idea, a feature, a ticket or work already in flight that ends in a contract — or in an honest **fog**.

`/align` is a mode, not an event. You invoke it to settle something, and you re-enter it when a requirement moves, a slice splits, or a fact turns out to be wrong. Each pass raises the resolution of the **Alignment artefact**; the artefact advances, not the session count.

`/align` works on a **Ticket** when one exists, and creates one only once the work is worth tracking — never on entry. The ticket it holds sits in `needs-alignment`, which means **the body is not yet the contract** — a draft until a pass closes it **aligned**, so nothing downstream reads it before then. The body stays the alignment's record of intent; cutting it into work is stage 2's.

Every step below assumes the loop: one question at a time, facts looked up rather than asked, decisions kept with the operator.

## 1. Name the entry

One procedure, four entries. Establish which you have before asking anything.

| argument | entry | first move |
| --- | --- | --- |
| an idea or a feature | **first pass** | nothing yet — no ticket, no branch; the ticket arrives when a pass has a record to publish (step 7) |
| a ticket at `needs-alignment`, or one whose contract has moved | **re-entry** | read the artefact and the last pass comment **before** anything else |
| work already in flight — a branch, an open pull request, a merged change | **as-built** | read the work first: `gh pr view <ref> --json body,comments,reviews` and `git diff <base>...<head>`; seed **Unresolved** from the threads that are open *questions*, not defects |
| a defect with no decision behind it | **not this skill** | name the owner — `/diagnose`, `/crucible`, `/review` — say what it owns instead, and stop |

An entry `/align` does not own is refused in one line, with its route. A pass never re-asks a question the work has already answered: the answer becomes a decision row, and only what the work left open gets asked. On a re-entry, name what changed and which **Scenario** it touches. Re-asking a settled question wastes the artefact and restarts an interview the operator has already sat through. A body with no `**Pass:**` header predates `/align` — it is not an artefact yet, and step 7 preserves it before anything is rewritten.

**Done when** you know the pass number, the ticket whose body you will revise, and — on a re-entry or an as-built pass — the delta since the last pass.

## 2. Gather facts

Look them up. Every fact on the table is one fewer question the operator has to answer, and one fewer place an assumption can take root. Check what is already settled before anything else — `docs/adr/`, `CONTEXT.md`, the body and pass comments of a ticket already in flight, the reviews and threads of work already in flight — because a no that is already recorded ends the pass in minutes and creates nothing.

The fetch is not optional. An as-built pass reads the work — `gh pr view <ref> --json body,comments,reviews`, `git diff <base>...<head>` — before it asks anything, and every pass's header carries a `Verified against` commit it resolved for real: the branch tip, the pull request's head, or the commit the facts were checked against. A pass that fetched nothing outside the body is **thin** by definition.

Delegate the legwork: trace request paths, grep for consumers, read the docs of anything being integrated with, establish what the data actually permits, find what the current practice is for this shape of problem. Fan several out at the top of the pass rather than one at a time, and bring the findings back into the conversation.

Run the **four-pass discipline** before the pass can close: trace request paths rather than listing modules; grep for consumers; sketch `CONTEXT.md` if the repo has none; check for feature flags and branches that hide parallel surfaces. All four, because a ticket that skipped them names nothing that can be opened or grepped — and "the agent had judgement" is not a substitute for them.

Every claim carries where it came from, and anything without a source is **labelled as an assumption** rather than stated as fact. Freshness is per subject: record the commit or date a fact was checked against, so a later pass re-checks only what moved. Where a fact is worth having and the operator would otherwise gather it by hand, say what to run.

**Done when** every claim in the artefact is sourced or labelled an assumption, `Verified against` resolves to a real commit, and all four passes have run.

## 3. Enumerate the scenarios

Name the concrete walks through the system this work has to handle — *a publisher posts a carousel of four images*; *a publisher posts a carousel where one image is 1:1*. These are what the rest of the pass is argued against, and the list is what the gate counts.

A first pass into fog may only yield one or two. That is the finding, and it is what fog is. Do not invent scenarios to fill the list.

**Done when** every scenario you can name is written down, and each is concrete enough that changing an option visibly changes it.

## 4. Walk the loop

Interview the operator until the decision tree closes — the loop is `/align`'s own, long or short as the work is. One question at a time, and wait for the answer: a question the pass raises is closed only by the operator's answer, never by the pass itself, and an item raised and closed in the same turn stays unresolved.

Weave each question through a scenario — *"Scenario: a publisher posts four images where one is 1:1 — under option a the whole post is rejected, under option b we crop. Which?"* — so an option shows its impact instead of being argued in the abstract.

Carry a **recommendation and a plain-English reason** with every question. Drop the jargon: say what we are trying to do in the words the operator would use, not the words the model finds comfortable.

The questions come from the artefact's own gaps and drain one per turn: a scenario with no outcome, an interface still sketched, a decision with no rejected alternative, an axis marked `N/A` whose note is not a fact you looked up. An answer settles a row, opens an unresolved entry with its route, or spawns a new scenario, interface or axis note — and so its own questions.

Where the conversation stalls, or an answer arrives too easily, [ANTI-PATTERNS.md](./ANTI-PATTERNS.md) names the pattern and the question that surfaces it. Ask it; do not lecture it.

Sketches are welcome and stay rough. The operator's whiteboard form — a pseudo-interface, a half-drawn shape — is an input, not a document: take it as written, mark what is unresolved, and leave it in the notation it arrived in.

**Done when** the queue is empty — every scenario has an outcome, and every settled decision carries its reason and its rejected alternatives. The pass ends when the operator confirms the shared understanding, not when the artefact looks complete, and not before the decision table has been read back and confirmed.

## 5. Draw what is settled

Diagrams are how both sides see the same flow, so the pass draws one the moment a flow changes rather than saving it for the end. One diagram per flow this pass touched — two are fine when the feature has two genuinely different walks; a flow that already stands is referenced, never redrawn. Flow, lifecycle, interfaces and module depth each have a form that carries them and a form that does not; [DIAGRAMS.md](./DIAGRAMS.md) holds the conventions, including how participants are declared.

The move that matters: an interface starts as a **sketch** and is promoted to **settled** when its decision lands. The fence tag records which it is. A sketch holds the operator's questions; a settled interface holds the answers, and only the second can be built from.

**Done when** every interface the work touches is named, and every one already decided is settled rather than sketched.

## 6. Mark every axis

An **axis** is one dimension of the change every pass must answer for — happy path, failure, permissions and the rest. Walk the list once per pass, at session level rather than per scenario, marking each one **decision**, **N/A** or **out of scope**:

happy path · limits · failure · misuse · concurrency and idempotency · permissions · data volume · observability · migration · rollback · cost · timezone

Every axis gets a mark. This is the richness control and it is cheap: *N/A* is the honest answer most of the time. A pass with an empty N/A column is a thin pass — it means the axes were never asked, not that they did not apply.

Anything marked out of scope is written down **with its reason**, because that is what stops a reviewer, an agent or a colleague re-opening a decision already taken.

**Done when** no axis is unmarked, and every out-of-scope item carries its reason.

## 7. Close the pass

The close is the decision, and it carries the weight: which **verdict**, what happens next, and what is still open.

| verdict | test | what you recommend |
| --- | --- | --- |
| **aligned** | the gate below is met | stage 2 — publish the contract |
| **fog** | unresolved items remain, and each carries what would resolve it | another pass, with the routes as its plan |
| **dropped** | the work is not worth doing | nothing new is created; an existing ticket goes to `wontfix` |
| **thin** | unresolved items with no route, axes unmarked, or no decisions recorded | say plainly that the pass did not dig |

Fog is a finding, not a failure, and it is not knowable at invocation — which verdict a pass returns is decided here, with the most information you will ever have. Fog and thin look identical from the outside, and the route attached to each open question is the only thing separating an honest fog from a shrug. **Dropped** is a finding too, in two shapes. On a first pass it is a dismissal, and the cheapest one: no branch, no artefact, no ticket. On a later pass the record already exists, so the pass revises the body with the decision and its reason, and moves the ticket to `wontfix`.

**The gate.** The artefact is a contract when:

- every scenario has an outcome
- every interface the work touches is named
- every axis is marked
- every unresolved item carries what would resolve it — at zero, for **aligned**
- every participant in every diagram resolves to a term in the repo's `CONTEXT.md`

Report the gate as one line per item, each met or unmet **with where the evidence sits** — the evidence is named, never restated — then recommend. "Not complete" is the normal answer, and on a first pass into fog it is the correct one.

**Where the writing goes.** When the pass decides a repo document changes — a `CONTEXT.md` term, an ADR, research worth keeping — ask before writing anything, with a recommendation and three answers: a `docs/` branch off the trunk, which becomes a stack's base layer · the branch the pass was called about, which becomes the work surface and the stack's base · straight to main, no stack. Which document belongs beneath the work and which beside it is the operator's call, not the pass's. Nothing is written until they answer.

Then update the ticket **body** to [ARTEFACT.md](./ARTEFACT.md)'s shape — revised in place, headings stable, carrying the pass number and the commit the facts were checked against.

A body with no `**Pass:**` header predates `/align`. Post it verbatim as one comment — `### Original body — preserved at first pass` — before rewriting, and never edit that comment.

Post **one** comment carrying the pass's delta: the verdict, what moved since the last pass, each changed decision as a one-line row, a diagram per flow this pass touched, and where the writing went if it went anywhere. Each unresolved item the pass closed names what closed it — a commit, a `file:line`, a command output, or the operator's words. Nothing else. A decision's argument lives in the body's table, or in an ADR when a row cannot carry it; an unchanged flow is referenced, not repeated. The body is the current truth; the comments are how it got there.

A ticket is never created on entry: offer one when the verdict is **fog** and the routes are worth tracking, or **aligned**, and create it on the operator's word. On **aligned**, set the exit state: `ready-to-cut` when the work can be cut now, `ready-to-propose` when the destination names a proposal. Which of the two is the operator's call — whether someone else's yes is needed is a social fact the pass cannot read off the repo. A **dropped** pass has a ticket only if an earlier pass earned it. A branch is written only where the write ask was answered, and nothing else about the alignment lands on one.

**Done when** the operator has the verdict and the choice to continue, and the record matches it: the body current, one comment carrying this pass, and nothing created when a first pass closes **dropped**.

## Where this goes next

Stage 2 is `/cut`: it reads the body and cuts it into **Ticket**s — vertical, independently valuable, linked by native blocking edges, so the **frontier** stays one flat query — rather than rewriting it, so the body stays true to the intention it records. Where the destination is a proposal, `/propose` asks first and the ticket waits in `awaiting-decision`. **Layer**s are cut in stage 3: horizontal, by code dependency, one branch and one pull request each, inside that ticket's own stack.

Branch names are semantic throughout: `docs/` for the ADR, `CONTEXT.md` and research; `feat/` and `fix/` for work.

## Related

- `/domain-modeling` — the participant roles and the `CONTEXT.md` check are its territory. Invoke it rather than restating the model here.
- `/codebase-design` — deep modules and interface design, for the table in step 5.
- `/wayfinder` — charting genuinely foggy ground into investigation tickets. `/align`'s unresolved list covers most of what it did.

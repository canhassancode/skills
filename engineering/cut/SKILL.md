---
name: cut
description: Cut a settled alignment into vertical slices a builder can pick up cold — one ticket per slice, carrying the interfaces, scenarios, criteria, decisions and rejections that bear on it. Use when a ticket sits at ready-to-cut, when the operator asks to slice, break down or ticket up settled work, or straight after an alignment closes aligned.
argument-hint: <ticket-ref>
disable-model-invocation: true
---

# Cut

Stage 2. `/cut` reads an aligned body and turns it into **slices** — the work, one ticket each.

It decides nothing. Every line a slice carries is copied from the contract, because the cut is an act of assignment rather than of design, and copied material cannot drift from its source. Where a slice cannot be written from the contract, the contract is short: say so and send the work back for an `/align` pass rather than filling the gap with prose written at the cut.

Run it against a ticket at `ready-to-cut`. With no ticket there is nothing to cut — the alignment has not closed.

## 1. Read the contract

Fetch the ticket through the tracker adapter and read the **body**: what we are trying to do, the scenario table, the settled interfaces, the decision table, the axes, out-of-scope, the unresolved list, and the `**Destination:**` line.

Check the gate still holds — unresolved at zero, every axis marked, every interface settled rather than sketched. Short of that it is not a contract, and cutting it produces guesses with ticket numbers on them.

**Done when** you can name the destination, every scenario, and every interface the work touches.

## 2. Assign the contract to the slices

Walk the contract once and give each item a home:

- **Every scenario lands in exactly one slice.** A scenario nobody builds means the cut is wrong; a scenario in two slices means the slices overlap and will be built twice.
- **Every interface is owned or consumed** — owned by the slice that settles its behaviour, consumed by the slices that call it.
- **Every decision binds the slices it touches**, and travels with them, along with the alternatives it rejected.
- **Out-of-scope and decided-against entries are carried to the slices where a builder would otherwise re-open them.**

**Done when** nothing in the contract is unassigned, and no slice carries anything the contract does not.

## 3. Test each slice

Three tests, all mechanical:

- **Vertical.** A slice that cannot name the **scenario it makes pass** is a layer, not a slice. Horizontal work is real, but it is stage 3's — a branch and a pull request, never a tracker node.
- **Sized.** One slice fits one fresh context window. Too big is a slice that cannot be built in one sitting; too small is a slice whose own scenario it cannot name.
- **Sequenced.** Declare the blocking edges, and prefer prefactoring first — make the change easy, then make the easy change. A **wide refactor** is the exception to vertical slicing: one mechanical change whose blast radius fans across the codebase, so no single slice can land green. Sequence it as expand → migrate → contract. Expand first, adding the new form beside the old so nothing breaks. Then migrate callers in batches sized by blast radius, each batch its own slice blocked by the expand. Then contract, deleting the old form in a slice blocked by every batch.

**Done when** every slice passes all three, or has been split, merged or re-cut until it does.

## 4. Title each slice

One sentence, affirmative, specific, sentence case, no internal names — *Carousels reject off-ratio images before upload*, not *Add ratio validation to `Normaliser`*. Where the deliverable is a removal or a chore, the imperative carries it honestly: *Delete the old ratio column*.

The test: read it aloud to someone who has never seen the project, and they can say what changes. The rules and the reasoning are in [SLICE.md](./SLICE.md).

**Done when** every title passes that test, and no title names a module, a file or a layer.

## 5. Write the slice bodies

Write each body to [SLICE.md](./SLICE.md)'s template, by transclusion from the contract. Every scenario, interface, decision and rejection on a slice is copied verbatim — copying is safe, re-describing is how the ambiguity comes back.

**Done when** each slice reads as a complete brief on its own: a builder who never opens the parent can build it.

## 6. Quiz the operator

Present the slices before publishing anything — one table of title, what it delivers, its blocking edges and what it inherits — and one question: is this granularity right, does each edge genuinely gate the slice it blocks, and should any slice merge or split? Iterate until the operator approves.

**Done when** the operator has approved the breakdown.

## 7. Publish

The route follows the content:

- **One slice** — the alignment ticket **graduates**: it keeps its number, gains the slice's sections at the top of its body, and its contract stays intact below. Nothing new is created.
- **Several slices** — publish each as a **top-level issue**, with native blocking edges where the tracker has them and the `Blocked by` line where it does not. Where the tracker has a container — a Linear Project, a project or milestone — put them in it and let the container carry the effort. Then **close the alignment ticket** with one comment naming the slices. Never sub-issues: the parent closes, so nesting would hang work off something dead.

Apply `ready-to-build` to what can now be taken, and leave the closing comment naming what it was cut into, so the record and the board agree.

**Done when** the slices exist, the edges resolve, the parent's fate matches the route, and nothing is left at `ready-to-cut`.

## Where this goes next

Stage 3 cuts what a slice contains: **layers**, by code dependency, one branch and one pull request each, inside that slice's own `gh stack`. One stack per slice; the layers are its pull requests, and an agent takes one layer at a time. `/cut` does not create branches.

## Related

- `/align` — the pass that settles the contract this reads, and the destination that decides the route.
- `/propose` — the branch taken when the contract needs someone else's yes before any of this is cut.
- `/to-tickets` — the same slicing rules against a spec rather than an alignment body.
- `/codebase-design` — deep modules and interface design, when a slice's shape is still in question.

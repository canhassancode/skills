---
status: accepted
---

# `/align` admits work in flight, `/build` declares its shape, and one policy reviews

Supersedes [ADR-0005](./0005-align-owns-the-planning-entry.md) in part: its entry list and its branch rule. Its core decision — `/align` owns the planning entry and the alignment state — stands.

## Context

The planning lane ran for a day and three gaps showed.

**A pass could be authored whole.** `/align`'s entries were both states where the work does not yet exist, and everything a pass produces is written by the pass. The one clause that made the grilling loop external — *do not enact until I confirm we've reached a shared understanding* — did not survive into step 4, though ADR-0005 promised the interview loop "retained intact". So a pass ends when the artefact looks complete, judged by its author.

**Work that already exists had no entry.** A branch with an open pull request and review comments is neither a feature, an idea, nor a ticket. Nothing in the procedure reads it, so a session arriving with one has no step to follow and no way to be declined: it improvises the artefact, or never reaches `/align` at all.

**`/build` had one shape.** Layers exist because a ticket is often larger than one context window — the layer plan is what the window is spent against, and layering stays the recommendation for large work. But it was the only shape, so small work and work re-entering an existing branch were forced through `gh stack` flows that pay off only when there is more than one layer.

**The review policy had two engines, and `/review` used the weaker one.** `/crucible` is the stronger Spec axis — one hand-placed mutation per criterion, the consumer grep, attribution — and carries none of the Standards, Structure or Design axes that `code-review` has.

## Decision

**`/align` has four entries, and one of them refuses.**

First pass · re-entry · **as-built** on work already in flight · **not this skill**. An entry `/align` does not own is refused in one line, naming the owner (`/diagnose`, `/crucible`, `/review`), and the pass stops. An as-built pass reads the work before anything else — `gh pr view <ref> --json body,comments,reviews` and `git diff <base>...<head>` — and seeds **Unresolved** from the threads that are open *questions* rather than defects.

**A pass ends when the operator confirms it, not when the artefact looks complete.** A question the pass raises is closed only by the operator's answer, never by the pass itself; an item raised and closed in the same turn stays unresolved. A pass never re-asks a question the work has already answered — the answer becomes a decision row, and only what the work left open gets asked. Every settled decision carries a `rejected` alternative, or it is not settled. `Verified against` resolves to a real commit — the branch tip or the pull request's head — and a pass that fetched nothing outside the body is **thin**.

**Where a pass's repository writing goes is asked, not assumed.** When the pass decides a document changes — a `CONTEXT.md` term, an ADR, research worth keeping — it asks, with a recommendation, and the answers are: a `docs/` branch off the trunk, which becomes a stack's base layer · the branch the pass was called about, which becomes the work surface and the stack's base · straight to main, no stack. Nothing is written until the operator answers, and the pass's comment records where it went. `/align` does not care beyond asking well; the destination is the operator's.

**`/build` declares a shape before it cuts.** **Direct** — one branch, no stack — or **layered** — a stack, one branch per layer. Determined from the contract and the fit, then asked with a recommendation whose evidence is an expected invocation count. Layered is the recommendation whenever the contract does not demonstrably fit one builder invocation, because a ticket larger than a window is what layering exists to make buildable. Direct is a prediction, not a promise: a builder whose window fills hands back at a green commit and the remainder becomes a layer above it. Promotion is one-way. A branch that already has an open pull request stays open and skips the shipping half; a fresh direct branch ships as one draft, ticked and flipped the same way. Seats stay the three the run already had — delegated, in-session, self-review — and are no longer called modes, because shape and seats vary independently.

**`/crucible` is the review policy, and a superset of `/code-review`.** It carries four baselines — Standards (repo standards plus the Fowler smell baseline), Spec (the contract it already held), Structure (the structure baseline and the ladder) and Design (path-triggered on `DESIGN.md`) — so the `shape` class cites a standard rather than taste. A diff with no contract is reviewable: contract resolution runs commit references → argument → pull request body and its linked issue → ask; with none found there are no criteria, so nothing is falsified, and the review says so rather than inventing criteria from the diff. Its gate in that mode is the baselines, the consumer grep and regression. `/review`'s engine is `/crucible`. **`/code-review` stays registered and is not deprecated here** — the retirement fires once `/crucible` has run in anger under `/review`.

## Considered options

- **Keep `/align` pre-work-only and refuse in-flight work.** Rejected: work in flight is where the unnamed scenarios surface, so an as-built pass is the cheapest evidence a contract can be checked against. The risk — an artefact that rubber-stamps the code — is answered by the `rejected` requirement and by seeding Unresolved from the review, not by refusing the entry.
- **Delegate the interview back to `/grilling`.** Rejected: `/align` is the superset — scenarios to work against, sequence diagrams, interface discussions — and grilling never carried them. The family retires when `/align`'s loop is whole, which is what restoring the stop condition achieves; delegating it would leave the loop split across two skills.
- **A per-document destination taxonomy, and a `Writes:` header field.** Rejected: `/align` should not care where a document goes beyond asking well. The operator owns the destination, and the pass's comment is enough of a record.
- **Stack-only `/build`.** Rejected: a stack buys a reviewer a per-layer diff and a builder a budget, and neither is needed for work that fits one invocation. Forcing that work through `gh stack` costs a shadow stack for no review benefit.
- **Retire `/code-review` in this change.** Rejected: additive first, revertible without untangling a deprecation. The evidence is a run in anger under `/review`, not an argument.
- **Refuse to review a pull request with no contract.** Rejected: `/crucible` is meant to be a local greptile as well as an accountability gate, and a pull request with no ticket is the case it most needs to serve. The honesty lives in saying the falsification gate did not run, not in refusing the diff.

## Consequences

- `/align` is entered from four states, and a session holding none of them says so and stops with a route.
- A pass's question queue drains one answer per turn, and the artefact carries a `Verified against` commit that resolves.
- A re-aligned branch can become a stack's base layer, so `STACK.md`'s construction and resume flows accept an existing branch — and its head moves, which invalidates an in-flight review's SHA.
- `/build`'s plan and record are one row in direct shape; the `gh stack` flows apply only in layered shape, and the shipping half degenerates to one pull request.
- `/crucible` gains a companion baselines file and returns a verified list beside its findings; findings still carry one class, one severity, `found at` and `belongs to`, and never post.
- `/review`'s findings are `/crucible`'s, so an approval cites the verified list where a contract exists and names the gate that did not run where one does not.
- `/grilling`, `/grill-me`, `/grill-with-docs` and `/code-review` all stay registered and unchanged.
- ADR-0005's branch rule — "a branch is cut only when the work changes a repo document … nothing else about the alignment lands on one" — is superseded by the write ask, and its two-entry list by the four entries.

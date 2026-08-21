---
name: grilling
description: Grilling session — interview relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when the user wants to stress-test a plan, get grilled on their design, or mentions "grill me" / "grill-with-docs".
---

## Interview loop

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

If a *fact* can be found by exploring the environment (filesystem, tools, etc.), look it up rather than asking me. The *decisions*, though, are mine — put each one to me and wait for my answer.

Before designing failure, retry, or idempotency semantics around an existing function, read *that function's* error handling first — reasoning about it instead invents machinery the reused code already made unnecessary (CAR-833).

Do not enact the plan until I confirm we've reached a shared understanding.

## Second-brain awareness (if `~/Obsidian/` exists)

Probe for the gate with `ls ~/Obsidian/CLAUDE.md` — **never `test -f`**, which this zsh shadows with a vitest alias, so the probe silently runs the suite and reports failure. If that `ls` fails, skip this section silently — do not block. The gate is this file, not the vault directory, and its absence is never reported as "vault absent".

Open with a sweep — an index-first `/ask` on the session topic to surface prior grillings, ingested material, and Profile focus that bear on it. One topic sweep + targeted re-queries; never a blanket dump.

**Authority order** depends on whether the repo has its own canon:

- **Repo has `CONTEXT.md` / ADRs** → they are **canon**; the vault is *supplementary*. A Library page that contradicts live code is a flag to surface (*"your `Stripe Checkout` concept says webhook-as-truth, but this resolver reads the session — which is right?"*), never a fact to trust over the code.
- **No repo to ground against** → the vault is the *only* prior-art source. Weight it accordingly, but still treat any page as a snapshot to sanity-check — it may be stale.

# Tiers

Two questions set the route: does it fit one fresh build session, and does anyone know enough to spec it? Size decides parent or child; uncertainty decides whether to explore first.

|  | Known | Foggy |
|---|---|---|
| **Fits one session** | Child spec | Explore, then a child spec |
| **Bigger** | Parent spec → `/cut` | Explore, then a parent spec |

Above the grid sit two cases that need no plan. A one-sentence diff needs none: say so and stop. Neither does a change to one or two files with nothing left to decide. It is made in an ordinary session and reviewed by `/crucible`.

## Size

A child fits one session when:

- it is one capability a user or caller could notice on its own: vertical, never a layer;
- its acceptance criteria fit in about six lines;
- it is tested at one seam;
- a builder could finish it, Verify included, in one fresh context window. On brigade#136 each builder subagent ran 60–110k tokens.

Anything bigger is a parent. Its children are tracer bullets, each one observable alone.

## Uncertainty

An ask is foggy when the spec would rest on something nobody has seen. Each unknown takes one route, run as a subagent:

| The unknown is | Route |
|---|---|
| how something behaves when run: an API, a library, our own system | `/spike` |
| a fact written down somewhere: docs, standards, prior art | `/research` |
| a shape the user must see to judge: a UI, a state model, a flow | `/prototype` |

Each route gets one question in one sentence and returns one answer, which goes in Decisions. A question that can't be put in one sentence isn't ready for a route, so grill it first.

## Evidence

- The one-sentence rule: Claude Code best practices, "if you could describe the diff in one sentence, skip the plan".
- No spec for one or two files: a 50-ticket benchmark found a spec raised merge rates on large tickets (80% against 50%) and not on 1–2 file ones, where no spec was fastest (Uvik, Nov 2026; a consultancy benchmark, not peer-reviewed).
- One fresh context window per slice: Pocock's to-tickets; Anthropic, *Effective harnesses for long-running agents*, Nov 2025.
- The old 200-line budget was dropped: 9 of brigade#14's 10 merged children exceeded it, and nothing enforced it (ADR-0013).
- The grid is synthesis, not measured.

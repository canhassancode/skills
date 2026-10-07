---
name: domain-modeling
description: Build and maintain a project's domain model — challenge terms against the glossary, sharpen fuzzy language, stress-test with scenarios, cross-reference against code, and propose CONTEXT.md terms and ADRs for the user's yes before writing them. Use when domain terms need sharpening, a CONTEXT.md needs updating, or an ADR is worth recording.
---

## Domain awareness

During codebase exploration, look for existing documentation:

### File structure

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, pin down which thing they mean. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Prefer words people already use

A term must make sense to someone who wasn't in the room. Take the user's own word first, then the industry's, then a plain description — coin a new word only when all three fail, and say why. Never rename a phrase the user already uses ("per-repo queue" stays "repo queue", not "Lane"), and never turn an ordinary word into jargon. When the user asks what a term means, the term has failed: replace it rather than explain it.

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update CONTEXT.md inline, after a yes

When a term is resolved, propose it as its own one-line question — the term, its definition, one example of it in use — and write it to `CONTEXT.md` right there once the user says yes. Don't batch these up. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

Don't couple `CONTEXT.md` to implementation details. Only include terms that are meaningful to domain experts.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Offer each ADR as its own question, naming the three criteria it meets, show its text, and write it only after the user says yes to that ADR — never as one item in a "write all of these". Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

Skills that implement rather than align — `/build`, `/crucible`, `/diagnose`, `/tdd`, `/cut` — never write an ADR or a `CONTEXT.md` term. They raise one in their final report as a question for the user.

## Reference files

- [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) — the structure and rules for `CONTEXT.md`
- [ADR-FORMAT.md](./ADR-FORMAT.md) — the format and numbering for ADRs in `docs/adr/`
- [DOMAIN-AWARENESS.md](./DOMAIN-AWARENESS.md) — consumer rules for skills that explore a codebase (read the glossary, use its vocabulary, flag ADR conflicts)

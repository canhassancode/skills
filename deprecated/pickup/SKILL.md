---
name: pickup
description: Deprecated — superseded by /implement.
disable-model-invocation: true
---

# Pickup (deprecated)

Superseded by [`implement`](../../engineering/implement/SKILL.md). `pickup` was a standalone verification pass over a `ready-for-human` ticket: re-open the surfaces and consumers named in the agent brief, confirm they still match current code, then route on to `/tdd` or `/diagnose`. That risk — a brief gone stale against the branch — is one `implement` already absorbs, since it takes a ticket reference and fetches the brief itself.

`ready-for-human` survives; it partitions what an agent can be trusted to finish alone from what it cannot. What died is the ceremony in front of it.

Run `/implement <ticket>` instead.

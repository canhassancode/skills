---
name: pickup
description: Deprecated — superseded by /build.
disable-model-invocation: true
---

# Pickup (deprecated)

Superseded by [`build`](../../engineering/build/SKILL.md). `pickup` was a standalone verification pass over a `ready-for-human` ticket: re-open the surfaces and consumers named in the agent brief, confirm they still match current code, then route on to `/tdd` or `/diagnose`. That risk — a brief gone stale against the branch — is one `build` already absorbs: the ticket carries the contract, and each unit's brief is cut from it fresh.

Run `/build <ticket>` instead.

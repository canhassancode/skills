---
name: implement
description: Deprecated — superseded by /build.
disable-model-invocation: true
---

# Implement (deprecated)

Superseded by [`build`](../../engineering/build/SKILL.md). `implement` built a spec or a set of tickets in one session — TDD at pre-agreed seams, a regular typecheck, then a review before committing — leaving the window discipline and the review to judgement. `build` takes the ticket's contract as its input, runs it as a sequential loop of fresh-child units, gates each unit on `crucible` and ends at the pull request, so both are structural rather than advisory.

Run `/build <ticket-ref>` instead.

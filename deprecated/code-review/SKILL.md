---
name: code-review
description: Deprecated — superseded by /crucible.
disable-model-invocation: true
---

# Code review (deprecated)

Superseded by [`crucible`](../../engineering/crucible/SKILL.md). `code-review` reviewed the diff since a fixed point along four axes — Standards, Spec, Structure and Design — in parallel sub-agents. Those axes survive as the baselines in [`BASELINES.md`](../../engineering/crucible/BASELINES.md), which `crucible` checks against the contract in one pass that never posts.

Run `/crucible` instead — `/review` invokes it for a pull request and owns the voice and the posting.

---
name: tester
description: Deprecated — tests are written in the build loop by /build and /tdd.
disable-model-invocation: true
---

# Tester (deprecated)

Retired by [ADR-0013](../../docs/adr/0013-one-writer-per-ticket-and-no-locked-tests.md). `tester` wrote locked tests from the spec before any code existed and ran a validator against throwaway code. On brigade#136 all 22 locked tests passed against fakes while the feature didn't work. [`build`](../../engineering/build/SKILL.md) now writes tests in the loop with [`tdd`](../../engineering/tdd/SKILL.md) and proves each criterion with Verify steps on the running app. The test principles moved to [`tdd/good-vs-bad.md`](../../engineering/tdd/good-vs-bad.md) and [`tdd/layers.md`](../../engineering/tdd/layers.md).

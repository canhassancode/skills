---
name: tester-skips-bug-fix
description: A near miss — fixing a flaky existing unit test is not writing locked tests from a spec, so tester must not fire.
tags: [tester, triggering]
runs: 3
max_turns: 3
allowed_tools: [Skill]
---
The renewal unit test in src/billing/internal/renewal.test.ts fails about one run in ten on CI. Can you work out why and fix it?

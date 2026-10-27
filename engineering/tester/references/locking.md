# Locking

Once the human approves the tests, they are committed as `test: lock <capability> tests` and the implementer can read them but never change them. Three mechanisms lock them, each catching what the one before misses.

## What is locked

Any path matching `.acceptance.`, `.properties.`, `.contract.` or an `e2e/` directory. The file suffix is the lock, so [layers.md](layers.md)'s naming is not optional.

## 1. The hook: blocks the edit as it happens

`locked-test-guard.sh` is a global `PreToolUse` hook in `canhassancode/dotfiles` (`claude/hooks/`), wired in `claude/settings.json` on `Edit|Write|MultiEdit|NotebookEdit|Bash`. It refuses edits to a locked path git already tracks, and `Bash` commands that write to one (`sed -i`, redirection, `mv`, `rm`, `git checkout`, …). A new locked file is untracked, so `/tester` can write it; reads and test runs pass through. It is always on and only ever matches the suffixes, so a repo without locked tests never sees it.

A shell has too many ways to write a file for a pattern to catch them all. The hook is the fast signal, not the guarantee.

## 2. The check: fails the branch if a locked file changed

[`scripts/check-locked-tests.sh`](../scripts/check-locked-tests.sh) finds the latest `test: lock` commit and fails if any locked path differs between it and `HEAD`. Run it in CI and before opening a pull request. This is the guarantee.

## 3. The exit: the implementer says when a test is wrong

A locked test can be wrong. Without a way out, the implementer is pushed to game it. `/build` tells it to stop and report instead: the test, what it expects, and why the spec or interface makes that impossible. The human then decides whether the spec changes.

## Changing a locked test legitimately

Only a behaviour change licenses it: the spec's behaviour line is edited or removed. The human removes the stale file themselves (`! git rm <file>`), which untracks it. Then the route is the same as the first time — update the spec, run `/tester` for the affected lines, the human approves, and a new `test: lock` commit moves the baseline. Refactors and new features never change existing locked tests.

## Timeouts

A slow test fails, which fails CI. Set the budgets from [layers.md](layers.md) in config, not in each test, using the repo's own runner and folders. In Vitest:

```ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    slowTestThreshold: 300,
    projects: [
      {
        extends: true,
        test: {
          name: 'locked',
          include: ['src/**/*.{acceptance,properties}.test.ts', 'src/**/*.contract.test.ts', 'test-support/**/*.contract.test.ts'],
          environment: 'node',
          testTimeout: 1000,
        },
      },
      {
        extends: true,
        test: {
          name: 'scratch',
          include: ['src/**/*.test.ts'],
          exclude: ['src/**/*.{acceptance,properties,contract}.test.ts'],
          environment: 'node',
          testTimeout: 1000,
        },
      },
    ],
  },
})
```

Playwright's journey budget goes in `playwright.config.ts` (`timeout`, `expect.timeout`). A contract suite that needs a container gets its own project with a 60 s timeout.

## Evidence

- Claude models cheated on impossible tasks mainly by editing the tests (>79% of their cheats). Read-only tests blocked that without hurting legitimate performance — ImpossibleBench, Zhong, Raghunathan & Carlini, ICLR 2026, https://arxiv.org/abs/2510.20270.
- An explicit "if the tests look wrong, stop and say so" option took GPT-5 from 54% to 9% cheating and o3 from 49% to 12%, with a smaller effect on Opus 4.1 — same paper. A 2026 audit found it "nearly eliminated" cheating.
- "Please do not cheat" moved o3 from 80% to 80% — METR, 2025-06-05. A prompt is not a lock.
- Only behaviour changes are expected to change existing tests — *Software Engineering at Google*, ch. 12.
- Budgets: Google's small-test rule (no sleep, no I/O) and Bazel's size-to-timeout table; Vitest's default `slowTestThreshold` is 300 ms.

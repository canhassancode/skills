---
name: tester
description: Write the locked tests for an approved spec and interface before any implementation exists — module acceptance tests named by the spec's behaviour lines, contract suites for each port, properties for "always/never" rules, and the odd end-to-end journey — then prove each one fails for the right reason. Use after interfaces are approved in /align, or when the user asks to write acceptance, contract or locked tests from a spec.
context: fork
background: false
---

# Tester

Write the tests the implementation must turn green, from the spec and the approved interface only. Never read or write implementation code: a test written after seeing the code catches faults 14% of the time against 25% when written independently.

Origin: TDFlow (human-owned tests as the oracle, 94.3% vs 68.0%) and Konstantinou et al. 2026 (independence of context, not of model).

## Inputs

- The spec, which is the ticket's body: its `## Behaviour` lines are the test titles.
- The approved interface: the public signatures and ports, committed as stubs that compile and throw.

If either is missing, stop and say which.

## Conventions

Three are fixed, because the lock depends on them: the locked file suffixes (`.acceptance.`, `.properties.`, `.contract.`, an `e2e/` directory), titles equal to the behaviour lines, and the `test: lock` commit.

Everything else follows the repo: the runner, `it` or `test`, where tests and fakes live, factory and file naming, how timeouts are set. The references' examples are Vitest in one layout; translate them, don't import them. Fall back to the examples only where the repo has no tests yet.

## Steps

1. **Read the repo's conventions**: two or three existing test files, the test config and wherever fakes or helpers live. Note what you'll follow in the report.
2. **Place each behaviour line on a layer** using [references/layers.md](references/layers.md). Most go to module acceptance.
3. **Name each test with its behaviour line, word for word.** [references/naming.md](references/naming.md).
4. **Write the tests** using the reference for each layer:
   - [references/acceptance.md](references/acceptance.md)
   - [references/properties.md](references/properties.md)
   - [references/contract.md](references/contract.md)
   - [references/end-to-end.md](references/end-to-end.md)
5. **Check each test against** [references/good-vs-bad.md](references/good-vs-bad.md) before running it. Every argument is the value the framework has already decoded, never its wire encoding.
6. **Run them and confirm every test is red for the right reason**: an assertion failure, or the stub's not-implemented error, raised through the public interface. A compile error, missing import, missing fixture or timeout is the wrong reason; fix the test.
7. **Run the repo's typecheck over the tests.** A type error is fixed in the test, never silenced with a cast, `any` or an ignore comment. If only a fact the spec and repo don't give would fix it, such as which of the interface's values a behaviour line's term means, delete that test and report the line as a spec gap. If the repo has a typecheck that can't run, such as for missing dependencies, the `Typecheck:` line says `not run — <why>`, never clean, and it is also a typecheck gap. A repo with no typecheck reports `none in repo`, which passes like clean.
8. **Return the report** below, in its shape even when the tests couldn't run: each line still gets its layer and file, with `not run — <why>` as its red reason. You run as a fork, so your invoker relays the report and tends to reword it; the `Typecheck:` and `Gaps:` lines are what `/align` blocks the lock on, so the report opens with the relay line that tells it to pass them on word for word. Do not commit — the invoker commits after the human approves, using `test: lock <capability> tests`. [references/locking.md](references/locking.md) covers what the lock enforces.

## When a behaviour can't be tested

If a behaviour line can't be observed through the approved interface, don't reach into internals or invent a method. Report it as an interface gap; the interface goes back for approval.

## Report

```
Relay to the user as written: the Typecheck and Gaps lines below go word for word, never paraphrased or dropped.
Conventions followed: <runner, test function, test and fake locations — or "none found, used the reference examples">
Typecheck: <command> — clean | <errors, each also a gap> | not run — <why> | none in repo

| Behaviour | Layer | File | Red because |
|---|---|---|---|
| <behaviour line> | acceptance | src/billing/billing.acceptance.test.ts | expected { state: 'active' … }, received not implemented |

Gaps: <none, or one per line>
- interface — <behaviour> — <what the interface lacks>
- spec — <behaviour> — <the fact missing from spec and repo>
- green — <behaviour> — passes against the stubs
- stale lock — <file:line> — <the new line it contradicts>
- typecheck — <command> — <the error, or why it couldn't run>
Command: <the one command that runs exactly these tests>
```

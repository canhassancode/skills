# Layers

In a deep-module repo the test shape is a diamond. The bulk sits at each module's public interface, with fakes only at network and process ports. A thin layer of contract and end-to-end tests sits above it; a few scratch unit tests survive below it.

```
              ┌──────────────────────┐
              │  End-to-end          │  1–2 journeys per parent spec · locked
          ┌───┴──────────────────────┴───┐
          │  Contract                    │  one suite per port, run against
          │                              │  the fake AND the real adapter · locked
   ┌──────┴──────────────────────────────┴──────┐
   │  Module acceptance + properties            │  the bulk · locked
   │  public interface only, fakes at ports     │  one test per behaviour line
   └──────┬──────────────────────────────┬──────┘
          │  Scratch unit                │  written by the implementer, kept
          └──────────────────────────────┘  only if it kills a mutant above misses
```

## Which layer a behaviour line belongs to

| The behaviour line says… | Layer | File |
|---|---|---|
| What the module returns or becomes for a given input or state | Module acceptance | `<module>/<module>.acceptance.test.ts` |
| "always", "never", "for any", "at most once", an invariant over sequences | Property | `<module>/<module>.properties.test.ts` |
| How a third party answers: status codes, error mapping, payload shape | Contract | `<port>.contract.ts` beside the repo's fakes, plus one `*.contract.test.ts` per implementation |
| A user can get from page A to outcome B through the real wiring | End-to-end | `e2e/<journey>.spec.ts` |

The tester writes no scratch unit tests. They belong to the implementer.

## Layout

An example, for a repo with no tests yet. Where the repo already has a layout, use it; only the suffixes are fixed.

```
src/billing/
  index.ts                              createBilling and public types — the only export
  billing.acceptance.test.ts            locked
  billing.properties.test.ts            locked
src/ports/payment-gateway.ts            the port the module depends on
src/adapters/http-payment-gateway.ts
src/adapters/http-payment-gateway.contract.test.ts   locked
test-support/fake-payment-gateway.ts
test-support/fake-payment-gateway.contract.test.ts   locked
test-support/payment-gateway.contract.ts             locked
e2e/subscribe.spec.ts                   locked
```

The file suffix is the lock: `.acceptance.`, `.properties.`, `.contract.` and the `e2e/` directory. Name files exactly this way or the lock misses them.

## What gets a fake

Only ports: anything crossing the network or the process boundary (payment provider, clock, randomness, email). Storage gets a real in-memory implementation that the production adapter must also satisfy. Nothing inside the module is ever mocked.

## Speed budget per layer

Defaults where the repo sets none. A repo with stricter budgets keeps them.

| Layer | Environment | Per-test timeout |
|---|---|---|
| Acceptance, properties | `node`, in-process fakes, fake timers | 1 s |
| Contract | `node`, msw at the HTTP layer | 1 s |
| Contract against a container | localhost only, separate project | 60 s |
| End-to-end | Playwright | the journey's own budget, set in `playwright.config.ts` |

[locking.md](locking.md) has the config that enforces these.

## Evidence

- The diamond shape, the 1–2 journey count and the per-layer budgets are synthesis. The budgets follow Google's small/medium/large test sizes (*Software Engineering at Google*, ch. 11) and Bazel's size-to-timeout table.
- Agents mock more than humans (36% vs 26% of test commits) and use fakes less (32% vs 57% of repos) — Hora & Robbes, MSR 2026, https://arxiv.org/abs/2602.00409.
- Agent-generated long Playwright flows failed ~48% of the time — Slack Engineering, 2026-06-11.

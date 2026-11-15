# Layers

In a deep-module repo, tests form a diamond. Most sit at each module's public interface, with fakes only at network and process ports. Above them is a thin layer of contract tests and real journeys. Below them, a few unit tests earn their place.

```
              ┌──────────────────────┐
              │  Real journey        │  the spec's Verify steps, on the running app
          ┌───┴──────────────────────┴───┐
          │  Contract                    │  one suite per port, run against
          │                              │  the fake AND the real adapter
   ┌──────┴──────────────────────────────┴──────┐
   │  Module acceptance + properties            │  the bulk: public interface only,
   │                                            │  fakes at ports, one test per criterion
   └──────┬──────────────────────────────┬──────┘
          │  Unit                        │  kept only where a rule is too fiddly
          └──────────────────────────────┘  to pin through the interface
```

## Which layer a criterion belongs to

| The criterion says… | Layer |
|---|---|
| What the module returns or becomes for a given input or state | Module acceptance |
| "always", "never", "for any", "at most once", an invariant over sequences | Property |
| How a third party answers: status codes, error mapping, payload shape | Contract, against the fake and the real adapter |
| Something reaches the real process: an env var, a socket, a file, a page | Real journey, the Verify step that proves it |

A fake can't show that a value reached a real process. The criterion "the app's environment holds the key" passed against a fake app starter, and failed on the running app (brigade#136). Wiring like that is proved by a Verify step, never by a fake.

Follow the repo's layout and naming. Where it has no tests yet, put acceptance tests beside the module as `<module>.test.ts` and contract suites beside the port.

## What gets a fake

Only ports: anything crossing the network or the process boundary, such as a payment provider, the clock, randomness or email. Storage gets a real in-memory implementation that the production adapter must also satisfy. Nothing inside the module is ever mocked.

## Speed

Acceptance, property and contract tests run in milliseconds, with in-process fakes and fake timers. A test that needs a container or a real process lives in its own project and gets its own timeout.

## Evidence

- The diamond shape is synthesis. The speed split follows Google's small/medium/large test sizes (*Software Engineering at Google*, ch. 11).
- Agents mock more than humans (36% vs 26% of test commits) and use fakes less (32% vs 57% of repos) — Hora & Robbes, MSR 2026, https://arxiv.org/abs/2602.00409.
- Agent-generated long Playwright flows failed ~48% of the time — Slack Engineering, 2026-06-11.

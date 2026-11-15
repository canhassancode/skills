# Property tests

Use a property only for a behaviour line that says "always", "never", "for any", "at most once", or states an invariant over a sequence of actions. Everything else is an example test in [acceptance.md](acceptance.md).

A property replaces the dozens of example tests an agent would otherwise write, and it can't be passed by special-casing the examples.

## Example

Behaviour line: *A user never holds more than one active subscription, and is charged once per successful subscribe.*

```ts
import fc from 'fast-check'
import { expect, it } from 'vitest'

type Command = { kind: 'subscribe'; cardToken: 'tok_ok' | 'tok_bad' } | { kind: 'cancel' }

const commandArbitrary: fc.Arbitrary<Command> = fc.oneof(
  fc.record({ kind: fc.constant('subscribe' as const), cardToken: fc.constantFrom('tok_ok' as const, 'tok_bad' as const) }),
  fc.record({ kind: fc.constant('cancel' as const) }),
)

it('a user never holds more than one active subscription, and is charged once per successful subscribe', async () => {
  await fc.assert(
    fc.asyncProperty(fc.array(commandArbitrary, { maxLength: 30 }), async (commands: Command[]): Promise<void> => {
      const { billing, gateway } = createHarness('2026-10-26T09:00:00Z')
      gateway.declineCard('tok_bad')
      let successfulSubscribes = 0

      for (const command of commands) {
        if (command.kind === 'cancel') {
          await billing.cancel('u1')
          continue
        }
        const result = await billing.subscribe({ userId: 'u1', plan: 'pro', cardToken: command.cardToken })
        if (result.ok) successfulSubscribes += 1
      }

      expect(gateway.charges()).toHaveLength(successfulSubscribes)
    }),
  )
})
```

The loop and branches drive the command sequence; they sit outside the assertion, which runs once on the final state. That is the one place a loop belongs in a locked test.

## Rules

- **Ground the property in the spec line,** not in what seems true of an implementation you imagine.
- **Generate commands, not raw values,** when the line is about sequences: subscribes, cancels, clock moves.
- **Keep runs small enough for the 1 s budget.** `maxLength` around 30 and fast-check's default 100 runs, in memory.
- **Ask "is this a real bug or a bad property?"** before reporting red. A property that is false of the spec is a broken locked test.

## Evidence

- Bug recall 42.1–83.4% with a property-scaffolded prompt vs 31.4–76.7% open-ended — PBT-Bench, NeurIPS 2026, https://arxiv.org/abs/2605.15229.
- 56% of agent-written property reports were valid, 86% of the top-ranked; ground properties in documentation and self-check for bad tests — Anthropic, 2026-01-14, https://www.anthropic.com/research/property-based-testing.

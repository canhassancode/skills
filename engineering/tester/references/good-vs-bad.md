# Good test vs bad test

A good test fails when the behaviour changes and passes when only the structure changes. Every check below is a way that breaks.

## Checklist

- **Strong oracle.** It asserts a value: `toEqual` on a return value or the state read back through the interface, or a specific error. Not existence, not a boolean, not a call, not a snapshot.
- **Public interface only.** It imports from the module's `index.ts`, never from `internal/`.
- **Fakes only at ports.** No `vi.mock` of anything inside the module under test.
- **Decoded values, not the wire.** Pass the interface what the framework hands it after decoding: the object a JSON scalar or body parser produces, the value a validated or coerced query parameter becomes. Never `JSON.stringify` a value or copy the request body's encoding; a sample request in the spec shows the wire, not the argument.
- **Arrange, act, assert, in that order.** One act per test. Fakes are only set up in arrange: which card declines, what time it is.
- **Deterministic.** Fake clock, fixed seeds, no reliance on collection order, no real network.
- **No waits.** No `setTimeout`, `sleep`, `page.waitForTimeout`. Poll for state or advance the fake clock.
- **No branches.** No `if`, `try/catch` or loops around an `expect`. A swallowed failure passes by construction.
- **Fast.** Milliseconds for acceptance; see the budgets in [layers.md](layers.md).

## A good test

```ts
it('subscribing with a declined card leaves the user unsubscribed and reports card_declined', async () => {
  const { billing, gateway } = createHarness('2026-10-26T09:00:00Z')
  gateway.declineCard('tok_bad')

  const result = await billing.subscribe({ userId: 'u1', plan: 'pro', cardToken: 'tok_bad' })

  expect(result).toEqual({ ok: false, reason: 'card_declined' })
  expect(await billing.getStatus('u1')).toEqual({ state: 'none' })
})
```

Both assertions are exact values from the public interface. The internals can be rewritten freely and this stays green while the behaviour holds.

## A bad test

```ts
vi.mock('./internal/renewal')
vi.mock('./internal/subscription-repository')

it('subscribe calls the renewal calculator and saves', async () => {
  vi.mocked(calculateRenewal).mockReturnValue('2026-11-26')

  await billing.subscribe({ userId: 'u1', plan: 'pro', cardToken: 'tok_ok' })

  expect(calculateRenewal).toHaveBeenCalledWith('pro', expect.any(Date))
  expect(saveSubscription).toHaveBeenCalledTimes(1)
})
```

- It mocks the module's own internals, which aren't ports.
- It asserts on calls, so it passes even if `getStatus` returns garbage.
- It breaks on any refactor that keeps the behaviour.
- It kills almost no mutants in `renewal.ts`, because the mock replaced that code.

## Weak oracles, named

| Weak | Looks like | Replace with |
|---|---|---|
| No assertion | the act, then nothing; or only `console.log` | `expect(result).toEqual(…)` |
| Existence only | `toBeDefined()`, `not.toBeNull()` | the exact expected value |
| Boolean only | `expect(isValid).toBe(true)` | the outcome the boolean stands for |
| Call only | `toHaveBeenCalled…` on a mock | the state read back through the interface |
| Snapshot only | `toMatchSnapshot()` | explicit fields that the behaviour line names |
| Loose matcher | `toMatchObject` or `expect.anything()` where the spec names the value | `toEqual` with the value |

`toMatchObject` is right in one place: a contract test asserting a field the third party generates, such as `chargeId: expect.any(String)`.

## Evidence

- 80.2% of 86,156 agent test-file patches carry a weak or no oracle; Claude Code's strong-oracle rate on new files is 67% — Banik et al., 2026-06-16, https://arxiv.org/abs/2606.18168.
- LLM tests lose pass rate (79%) and branch coverage (69%) on behaviour-preserving edits: the signature of tests coupled to structure — Haroon et al., 2026-03-24, https://arxiv.org/abs/2603.23443.
- "Test state, not interactions" — *Software Engineering at Google*, ch. 12. "Too much mocking, especially strict mocking, is a structure sensitivity nightmare" — Kent Beck, Test Desiderata.
- A property test passed only because a try/except swallowed the failure — Anthropic, agentic property-based testing, 2026-01-14.

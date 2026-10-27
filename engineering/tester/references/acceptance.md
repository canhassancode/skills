# Module acceptance tests

The bulk of the suite. One test per behaviour line, through the module's public interface, with fakes only at ports. Every test runs in memory in milliseconds.

## What you start from

The approved interface, committed as a stub that compiles and throws:

```ts
export type BillingDependencies = {
  clock: Clock
  gateway: PaymentGateway
  store: SubscriptionStore
}

export type SubscriptionStatus =
  | { state: 'none' }
  | { state: 'active'; plan: Plan; renewsOn: string }
  | { state: 'cancelling'; plan: Plan; endsOn: string }
  | { state: 'expired'; plan: Plan }

export type SubscribeResult = { ok: true } | { ok: false; reason: 'card_declined' | 'already_subscribed' }

export type Billing = {
  subscribe(request: { userId: string; plan: Plan; cardToken: string }): Promise<SubscribeResult>
  cancel(userId: string): Promise<void>
  getStatus(userId: string): Promise<SubscriptionStatus>
}

export function createBilling(dependencies: BillingDependencies): Billing {
  throw new Error('createBilling is not implemented')
}
```

The tests depend on these signatures and nothing else. If a behaviour needs something the interface doesn't expose, that is an interface gap: report it.

## The harness

One function builds the module with its fakes and hands back the fakes the tests arrange:

```ts
type Harness = { billing: Billing; gateway: FakePaymentGateway; clock: FixedClock }

function createHarness(now: string): Harness {
  const gateway = createFakePaymentGateway()
  const clock = createFixedClock(now)
  const billing = createBilling({ clock, gateway, store: createMemorySubscriptionStore() })
  return { billing, gateway, clock }
}
```

Fakes live in `test-support/` and are shared with the contract suite, which keeps them honest. If a fake doesn't exist yet, write it there; it is test code and gets locked with the rest.

## Example

```ts
import { describe, expect, it } from 'vitest'
import { createBilling, type Billing } from '../billing'
import { createFakePaymentGateway, type FakePaymentGateway } from '../../test-support/fake-payment-gateway'
import { createFixedClock, type FixedClock } from '../../test-support/fixed-clock'
import { createMemorySubscriptionStore } from '../../test-support/memory-subscription-store'

describe('billing', () => {
  it('subscribing with an accepted card activates the plan, renewing one calendar month on', async () => {
    const { billing } = createHarness('2026-10-26T09:00:00Z')

    await billing.subscribe({ userId: 'u1', plan: 'pro', cardToken: 'tok_ok' })

    expect(await billing.getStatus('u1')).toEqual({ state: 'active', plan: 'pro', renewsOn: '2026-11-26' })
  })

  it('cancelling keeps access until the period ends, then the subscription expires', async () => {
    const { billing, clock } = createHarness('2026-10-26T09:00:00Z')
    await billing.subscribe({ userId: 'u1', plan: 'pro', cardToken: 'tok_ok' })

    await billing.cancel('u1')
    const duringPeriod = await billing.getStatus('u1')
    clock.set('2026-11-26T09:00:01Z')
    const afterPeriod = await billing.getStatus('u1')

    expect(duringPeriod).toEqual({ state: 'cancelling', plan: 'pro', endsOn: '2026-11-26' })
    expect(afterPeriod).toEqual({ state: 'expired', plan: 'pro' })
  })
})
```

- Every assertion is on a value returned by the public interface.
- Setup arranges outcomes (which card declines, what time it is); it never scripts how the module gets there.
- Time moves by setting the fake clock, never by waiting.

## Red for the right reason

Run the file. Each test must fail with `createBilling is not implemented` or an assertion mismatch. Anything else — a type error, a bad import path, a fixture that doesn't exist — means the test is broken, and a broken locked test is the worst outcome: the implementer can't fix it and will be pushed to work around it.

## Evidence

- Spec-derived tests written before the code: TDFlow, 94.3% vs 68.0% with LLM-written tests, https://arxiv.org/html/2510.23761v1; independent tests detected faults 25% vs 14% after seeing faulty code, https://arxiv.org/abs/2607.05139.
- A wrong test pushes even an honest model towards a "cheat" — Mendelsohn's ImpossibleBench audit, 2026-10-12.

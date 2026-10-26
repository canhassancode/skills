# Test layers for deep-module repos with locked acceptance tests: worked examples

Illustrative TypeScript (Vitest, fast-check, msw, Playwright). It has not been run. The evidence behind each layer is in [agent-testing-research.md](agent-testing-research.md) and [spec-driven-agent-development-research.md](spec-driven-agent-development-research.md). The provenance section at the end says which parts are measured and which are synthesis.

## Shape

In a deep-module repo the "pyramid" is really a diamond. Most tests sit at each module's public interface, with fakes standing in only at network and process boundaries. A thin layer of contract and end-to-end tests sits on top, and only a handful of internal unit tests survive underneath.

```
              ┌──────────────────────┐
              │  E2E (Playwright)    │  3–5 user journeys · locked
          ┌───┴──────────────────────┴───┐
          │  Boundary contracts (Vitest  │  one suite per port, run against
          │  + msw)                      │  the fake AND the real adapter
   ┌──────┴──────────────────────────────┴──────┐
   │  Module acceptance (Vitest)                │  THE BULK · locked · from spec
   │  public interface only, fakes at ports     │  + properties for "for all…"
   └──────┬──────────────────────────────┬──────┘
          │  Internal unit (scratch)     │  survive only by killing a mutant
          └──────────────────────────────┘  the suite above misses
```

## Running example: billing module

Acceptance criteria from the spec:

- **AC1:** Subscribing with an accepted card makes the user `active`, renewing one calendar month on.
- **AC2:** A declined card leaves the user with no subscription and returns `card_declined`.
- **AC3:** Cancelling keeps access until the period ends, then the state is `expired`.
- **AC4:** For any sequence of subscribes and cancels, a user never has more than one active subscription.

## Layout

```
src/billing/
  index.ts                          createBilling + public types — the only export
  internal/renewal.ts
  internal/renewal.test.ts          scratch
  billing.acceptance.test.ts        locked
  billing.properties.test.ts        locked
src/ports/payment-gateway.ts        the interface the module depends on
src/adapters/http-payment-gateway.ts
src/adapters/http-payment-gateway.contract.test.ts
test-support/fake-payment-gateway.ts
test-support/payment-gateway.contract.ts
e2e/subscribe.spec.ts               locked
```

Lock the files with permissions, not a prompt: deny Edit/Write on `**/*.acceptance.test.ts`, `**/*.properties.test.ts` and `e2e/**`, and have CI fail any agent PR that touches them.

## The interface under test

The tests depend only on these signatures and never on `internal/`:

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

export function createBilling(dependencies: BillingDependencies): Billing
```

The three dependencies are the ports. Only `gateway` (network) and `clock` (process time) get fakes. `store` gets a real in-memory implementation that the production adapter must also satisfy.

## Layer 1: module acceptance tests (the bulk, locked)

```ts
import { describe, expect, it } from 'vitest'
import { createBilling, type Billing } from '../billing'
import { createFakePaymentGateway, type FakePaymentGateway } from '../../test-support/fake-payment-gateway'
import { createFixedClock, type FixedClock } from '../../test-support/fixed-clock'
import { createMemorySubscriptionStore } from '../../test-support/memory-subscription-store'

type Harness = { billing: Billing; gateway: FakePaymentGateway; clock: FixedClock }

function createHarness(now: string): Harness {
  const gateway = createFakePaymentGateway()
  const clock = createFixedClock(now)
  const billing = createBilling({ clock, gateway, store: createMemorySubscriptionStore() })
  return { billing, gateway, clock }
}

describe('billing', () => {
  it('AC1: activates with a renewal one calendar month on when the card is accepted', async () => {
    const { billing } = createHarness('2026-10-26T09:00:00Z')

    await billing.subscribe({ userId: 'u1', plan: 'pro', cardToken: 'tok_ok' })

    expect(await billing.getStatus('u1')).toEqual({ state: 'active', plan: 'pro', renewsOn: '2026-11-26' })
  })

  it('AC2: leaves the user unsubscribed and reports the decline when the card is refused', async () => {
    const { billing, gateway } = createHarness('2026-10-26T09:00:00Z')
    gateway.declineCard('tok_bad')

    const result = await billing.subscribe({ userId: 'u1', plan: 'pro', cardToken: 'tok_bad' })

    expect(result).toEqual({ ok: false, reason: 'card_declined' })
    expect(await billing.getStatus('u1')).toEqual({ state: 'none' })
  })

  it('AC3: keeps access until the period ends after cancelling, then expires', async () => {
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

What makes these tests behaviour tests rather than implementation tests:

- **Every assertion is on a return value of the public interface.** None checks "was X called".
- **Each `it` names its acceptance criterion.** That gives a reviewer the trace from spec to test.
- **Fakes are only set up.** The one exception is the stated outcome, such as which card declines.
- **Everything is in memory.** Each test runs in milliseconds.

The agent can rewrite everything in `internal/` and these tests stay green as long as the behaviour holds.

## Layer 1b: properties for "for all…" criteria (locked)

```ts
import fc from 'fast-check'
import { expect, it } from 'vitest'

type Command = { kind: 'subscribe'; cardToken: 'tok_ok' | 'tok_bad' } | { kind: 'cancel' }

const commandArbitrary: fc.Arbitrary<Command> = fc.oneof(
  fc.record({ kind: fc.constant('subscribe' as const), cardToken: fc.constantFrom('tok_ok' as const, 'tok_bad' as const) }),
  fc.record({ kind: fc.constant('cancel' as const) }),
)

it('AC4: never holds more than one active subscription, and charges once per successful subscribe', async () => {
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

One property here replaces dozens of example tests the agent would otherwise write.

## Layer 2: boundary contracts (keeping the fake honest)

One contract suite runs against both the fake and the real adapter, so the fake cannot drift from reality:

```ts
import { describe, expect, it } from 'vitest'
import type { PaymentGateway } from '../src/ports/payment-gateway'

type GatewayUnderTest = { gateway: PaymentGateway; arrangeDecline(cardToken: string): void }

export function describePaymentGatewayContract(name: string, create: () => GatewayUnderTest): void {
  describe(`${name} honours the payment gateway contract`, () => {
    it('returns a charge id for an accepted card', async () => {
      const { gateway } = create()

      const result = await gateway.charge({ cardToken: 'tok_ok', amountPence: 1200, idempotencyKey: 'k1' })

      expect(result).toMatchObject({ ok: true, chargeId: expect.any(String) })
    })

    it('reports card_declined for a refused card', async () => {
      const { gateway, arrangeDecline } = create()
      arrangeDecline('tok_bad')

      const result = await gateway.charge({ cardToken: 'tok_bad', amountPence: 1200, idempotencyKey: 'k2' })

      expect(result).toEqual({ ok: false, reason: 'card_declined' })
    })
  })
}
```

The real adapter runs the same suite, with the mock at the HTTP layer via msw:

```ts
import { http, HttpResponse } from 'msw'
import { setupServer } from 'msw/node'
import { afterAll, afterEach, beforeAll } from 'vitest'
import { createHttpPaymentGateway } from './http-payment-gateway'
import { describePaymentGatewayContract } from '../../test-support/payment-gateway.contract'

const baseUrl = 'https://api.payments.test'
const declinedTokens = new Set<string>()

const server = setupServer(
  http.post(`${baseUrl}/v1/charges`, async ({ request }) => {
    const body = (await request.json()) as { source: string }
    if (declinedTokens.has(body.source)) {
      return HttpResponse.json({ error: { code: 'card_declined' } }, { status: 402 })
    }
    return HttpResponse.json({ id: 'ch_123', status: 'succeeded' })
  }),
)

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => declinedTokens.clear())
afterAll(() => server.close())

describePaymentGatewayContract('http adapter', () => ({
  gateway: createHttpPaymentGateway({ baseUrl, apiKey: 'test-key' }),
  arrangeDecline: (cardToken: string): void => {
    declinedTokens.add(cardToken)
  },
}))
```

The fake's own test file is a single line:

```ts
describePaymentGatewayContract('fake', () => {
  const gateway = createFakePaymentGateway()
  return { gateway, arrangeDecline: gateway.declineCard }
})
```

msw intercepts the HTTP call, so the adapter's real code runs: serialisation, status mapping, headers. Nothing inside the module is mocked anywhere in the repo.

## Layer 3: end-to-end (a few, locked)

```ts
import { expect, test } from '@playwright/test'

test('a visitor subscribes to Pro and sees when it renews', async ({ page }) => {
  await page.goto('/pricing')

  await page.getByRole('button', { name: 'Choose Pro' }).click()
  await page.getByLabel('Card number').fill('4242 4242 4242 4242')
  await page.getByRole('button', { name: 'Subscribe' }).click()

  await expect(page.getByRole('status')).toHaveText(/Pro · renews \d{1,2} \w+ \d{4}/)
})
```

This test proves the wiring: UI, routes, real store and provider sandbox. It does not re-test AC2–AC4, because layer 1 owns those. Use role and label selectors only, and don't let the agent generate or own long flows.

## Layer 0: scratch unit tests (earn a place or get deleted)

This one survives:

```ts
import { expect, it } from 'vitest'
import { addCalendarMonth } from './renewal'

it('clamps to the last day of a shorter month', () => {
  expect(addCalendarMonth('2026-01-31')).toBe('2026-02-28')
})
```

AC1 only exercises 26 October, so a mutation that drops the clamp survives the acceptance suite. This test catches it, so it stays. A test for `addCalendarMonth('2026-03-10')` catches no mutant the acceptance suite misses, so it gets deleted.

## What gets rejected in review

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

This test has four problems:

- **It mocks the module's own internals.** Those aren't boundaries.
- **It asserts on calls rather than outcomes.** It passes even if `getStatus` returns garbage.
- **It breaks on any refactor** that keeps the behaviour.
- **It is tautological.** It kills almost no mutants in `renewal.ts`, because the mock replaced that code.

The one-line `CLAUDE.md` rule that prevents it: *"Test through the module's exported interface; fake only ports in `src/ports/`; never `vi.mock` a path inside the module under test."*

## Who writes what

| Layer | Written by | Locked? | Gate |
|---|---|---|---|
| Acceptance + properties | Human, or a spec-only test agent with human approval | Yes | Must fail for the right reason before implementation |
| Contract suite | Human or agent, reviewed once per port | Yes | Runs against fake and real adapter |
| E2E journeys | Human | Yes | 3–5 total |
| Internal unit tests | Implementer agent | No | Kept only if it kills a mutant the locked suites miss |

## Provenance: measured vs synthesis

**Backed by the research:**
- **Acceptance tests first, written independently of the implementation:** TDFlow 94.3% vs 68.0%; tests written independently caught 25% vs 14% when written after the faulty code.
- **Locking tests:** ImpossibleBench, where read-only tests blocked test edits without hurting real performance.
- **Fakes over internal mocks:** agents add mocks in 36% of test commits vs 26% for humans, and use fakes in 32% of repos vs 57%.
- **Property-based tests for "for all" criteria:** PBT bug-recall studies and Kiro.
- **Few deterministic end-to-end tests:** Slack, about 48% failure for agent-generated long flows.
- **Mutation score over coverage:** MUTGEN found 100% coverage with a 4% mutation score; Meta's ACH.
- **Keeping a test only if it adds signal:** Meta TestGen-LLM filters (by coverage); MIST-RL mutation-guided selection, with 19.3% fewer tests and a higher mutation score.

**Synthesis, not measured in an agent context:**
- **The diamond shape itself.**
- **One contract suite shared by the fake and the real adapter:** an established practice that the research did not cover for agents ("contract testing with agents: anecdote only").
- **The 3–5 journey count.**
- **The exact keep rule:** keep a test only if it kills a mutant the locked suites miss.

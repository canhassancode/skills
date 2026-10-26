# Contract tests

One suite per port, run against the fake **and** the real adapter. It is what keeps the fake honest: if the fake drifts from the third party, the adapter run and the fake run disagree.

Write a contract suite whenever the spec introduces or changes a port. The behaviour lines it checks are the port's promises — how the third party answers — not the module's rules.

## The shared suite

`test-support/payment-gateway.contract.ts`:

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

`arrangeDecline` is how each implementation is told the outcome. The suite never knows whether it is talking to a fake or HTTP.

## The real adapter, with the network mocked at HTTP

`src/adapters/http-payment-gateway.contract.test.ts`:

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

msw intercepts the request, so the adapter's own serialisation, status mapping and headers run for real. `onUnhandledRequest: 'error'` turns a request the spec didn't foresee into a failure, not a silent pass.

The msw handlers encode what the third party actually returns. Take them from the provider's documentation or a recorded response, never from what the adapter happens to expect. If the docs and a recorded response disagree, report it; that is a spike, not a guess.

## The fake

`test-support/fake-payment-gateway.contract.test.ts`:

```ts
describePaymentGatewayContract('fake', () => {
  const gateway = createFakePaymentGateway()
  return { gateway, arrangeDecline: gateway.declineCard }
})
```

## Red for the right reason

Before the adapter exists, its run fails on the stub's not-implemented error. The fake's run may already pass if the fake was written alongside; that is fine, the fake is test code.

## Evidence

The shared suite for fake and adapter is established practice, but the research found only anecdote for contract testing with agents. The reason to keep fakes honest is measured: agents over-mock (36% vs 26% of test commits) and use fakes in fewer repos (32% vs 57%) — Hora & Robbes, MSR 2026.

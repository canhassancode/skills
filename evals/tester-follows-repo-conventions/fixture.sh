#!/usr/bin/env bash
set -euo pipefail

mkdir -p .scratch/billing/issues src/billing src/ports src/greeting/__tests__ src/testing

cat > package.json <<'JSON'
{
  "name": "billing-fixture",
  "private": true,
  "type": "module",
  "scripts": { "test": "vitest run" },
  "devDependencies": { "fast-check": "^4.0.0", "typescript": "^5.6.0", "vitest": "^5.0.0" }
}
JSON

cat > .scratch/billing/issues/01-billing.md <<'MD'
# Billing

Status: ready-to-build

## Behaviour

- Subscribing with an accepted card activates the plan, renewing one calendar month on.
- Subscribing with a declined card leaves the user unsubscribed and reports card_declined.
- Cancelling keeps access until the period ends, then the subscription expires.
- A user never holds more than one active subscription.

## Interface

Approved. See `src/billing/index.ts` and `src/ports/payment-gateway.ts`.
MD

cat > src/ports/payment-gateway.ts <<'TS'
export type ChargeRequest = { cardToken: string; amountPence: number; idempotencyKey: string }

export type ChargeResult = { ok: true; chargeId: string } | { ok: false; reason: 'card_declined' }

export type PaymentGateway = {
  charge(request: ChargeRequest): Promise<ChargeResult>
}
TS

cat > src/billing/index.ts <<'TS'
import type { PaymentGateway } from '../ports/payment-gateway'

export type Plan = 'pro' | 'team'

export type Clock = { now(): Date }

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

export type BillingDependencies = { clock: Clock; gateway: PaymentGateway }

export function createBilling(dependencies: BillingDependencies): Billing {
  throw new Error('createBilling is not implemented')
}
TS

cat > src/testing/fake-clock.ts <<'TS'
export function createFakeClock(start: Date): { now(): Date; advanceDays(days: number): void } {
  let current = new Date(start)
  return {
    now: (): Date => new Date(current),
    advanceDays: (days: number): void => {
      current = new Date(current.getTime() + days * 86_400_000)
    },
  }
}
TS

cat > src/greeting/index.ts <<'TS'
export function greet(name: string, now: Date): string {
  return now.getUTCHours() < 12 ? `Good morning, ${name}` : `Good afternoon, ${name}`
}
TS

cat > src/greeting/__tests__/greeting.test.ts <<'TS'
import { expect, test } from 'vitest'
import { greet } from '..'

test('greets in the morning before noon', () => {
  expect(greet('Ada', new Date('2026-01-01T09:00:00Z'))).toBe('Good morning, Ada')
})

test('greets in the afternoon from noon', () => {
  expect(greet('Ada', new Date('2026-01-01T12:00:00Z'))).toBe('Good afternoon, Ada')
})
TS

git init --quiet
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: approve billing interface"

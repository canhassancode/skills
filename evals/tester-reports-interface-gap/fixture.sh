#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/specs src/billing src/ports

cat > docs/specs/billing.md <<'MD'
# Billing

## Behaviour

- Subscribing with an accepted card activates the plan, renewing one calendar month on.
- Subscribing with an accepted card emails the user a receipt showing the amount charged.

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

export type SubscribeResult = { ok: true } | { ok: false; reason: 'card_declined' }

export type Billing = {
  subscribe(request: { userId: string; plan: Plan; cardToken: string }): Promise<SubscribeResult>
  getStatus(userId: string): Promise<SubscriptionStatus>
}

export type BillingDependencies = { clock: Clock; gateway: PaymentGateway }

export function createBilling(dependencies: BillingDependencies): Billing {
  throw new Error('createBilling is not implemented')
}
TS

git init --quiet
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: approve billing interface"

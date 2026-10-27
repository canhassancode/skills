#!/usr/bin/env bash
set -euo pipefail

mkdir -p src/checkout src/orders src/users

cat > package.json <<'JSON'
{
  "name": "shop-fixture",
  "private": true,
  "type": "module",
  "scripts": { "test": "vitest run" },
  "devDependencies": { "typescript": "^5.6.0", "vitest": "^5.0.0" }
}
JSON

cat > src/orders/order.ts <<'TS'
export type OrderStatus = 'paid' | 'awaiting_label' | 'shipped'

export type Order = {
  id: string
  status: OrderStatus
  totalPence: number
}
TS

cat > src/checkout/pay.ts <<'TS'
import type { Order } from '../orders/order'

export type PaymentProvider = {
  charge(amountPence: number): Promise<{ ok: boolean }>
}

export async function pay(order: Order, payments: PaymentProvider): Promise<Order> {
  const result = await payments.charge(order.totalPence)
  if (!result.ok) {
    return order
  }
  return { ...order, status: 'awaiting_label' }
}
TS

cat > src/users/users.ts <<'TS'
export type User = { id: string; email: string }

export function getUsr(users: User[], id: string): User | undefined {
  return users.find((user) => user.id === id)
}
TS

git init --quiet
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: checkout takes payment"

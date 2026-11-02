#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p .scratch/discount/issues src

cat > package.json <<'JSON'
{ "name": "discount-fixture", "private": true, "type": "module", "scripts": { "test": "node --test", "start": "node src/server.js" } }
JSON

cat > .scratch/discount/issues/01-discount.md <<'MD'
# Apply a discount

Status: needs-alignment

Branch: `feat/discount`, draft PR `.scratch/discount/pull-request.md`

## Goal
Show a discounted price, in pence, for a price and a percentage.

## Context
`src/server.js` serves GET /price. Prices come from the pricing feed at `PRICING_FEED_URL`.

## Interface
- `applyDiscount(pence: number, percent: number): number`

## Behaviour
- A 10% discount on 2000 pence gives 1800 pence.
- A discount above 100% is refused.

## Out of scope
Currency formatting: prices stay in pence.

## Done when
`npm test` passes.

## Verify
- Start: `npm start` (port 3000)
- GET /price?pence=2000&percent=10 → 200 with `1800`
- GET /price?pence=2000&percent=150 → 400 with "Discount above 100%"
- With the pricing feed down, GET /price shows "Prices unavailable"

## Decisions
- 2026-10-30 Q: Round a fractional result? → A: Down to the whole penny.
MD

cat > src/server.js <<'JS'
import { createServer } from 'node:http'
import { applyDiscount } from './discount.js'

createServer((request, response) => {
  const url = new URL(request.url, 'http://localhost')
  try {
    const price = applyDiscount(Number(url.searchParams.get('pence')), Number(url.searchParams.get('percent')))
    response.writeHead(200).end(String(price))
  } catch (error) {
    response.writeHead(400).end(error.message)
  }
}).listen(3000)
JS

git init --quiet --initial-branch=main
git add package.json .scratch/discount/issues/01-discount.md
commit "chore: init shop"

git switch --quiet --create feat/discount

cat > src/discount.js <<'JS'
export function applyDiscount(pence, percent) {
  throw new Error('not implemented')
}
JS
git add src/discount.js src/server.js
commit "feat: stub discount interface"

cat > src/discount.acceptance.test.js <<'JS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { applyDiscount } from './discount.js'

test('A 10% discount on 2000 pence gives 1800 pence.', () => {
  assert.equal(applyDiscount(2000, 10), 1800)
})

test('A discount above 100% is refused.', () => {
  assert.throws(() => applyDiscount(2000, 150), RangeError)
})
JS
git add src/discount.acceptance.test.js
commit "test: lock discount tests"

#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p .scratch/price/issues src

cat > package.json <<'JSON'
{ "name": "price-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > .scratch/price/issues/01-price.md <<'MD'
# Apply a discount

Status: ready-to-build

## Goal
Apply a percentage discount to a price held in pence.

## Interface
- `applyDiscount(pence: number, percent: number): number`

## Behaviour
- A 10% discount on 2000 pence gives 1800 pence.
- A discount above 100% is refused.

## Out of scope
Currencies other than pounds.
MD

cat > src/price.js <<'JS'
export function applyDiscount(pence, percent) {
  throw new Error('not implemented')
}
JS

cat > src/price.acceptance.test.js <<'JS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { applyDiscount } from './price.js'

test('A 10% discount on 2000 pence gives 1800 pence.', () => {
  assert.equal(applyDiscount(2000, 10), 1800)
})

test('A discount above 100% is refused.', () => {
  assert.throws(() => applyDiscount(2000, 150), RangeError)
})
JS

git init --quiet --initial-branch=feat/price
git add package.json .scratch/price/issues/01-price.md src/price.js src/price.acceptance.test.js
commit "test: lock price tests"

cat > src/price.js <<'JS'
export function applyDiscount(pence, percent) {
  if (percent < 0 || percent > 100) {
    throw new RangeError('percent out of range')
  }
  return Math.round((pence * (100 - percent)) / 100)
}
JS

cat > src/price.test.js <<'JS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { applyDiscount } from './price.js'

test('applies ten percent', () => {
  assert.equal(applyDiscount(2000, 10), 1800)
})

test('returns a number', () => {
  assert.equal(typeof applyDiscount(1000, 20), 'number')
})

test('rounds a half penny up', () => {
  assert.equal(applyDiscount(999, 50), 500)
})
JS

git add src/price.js src/price.test.js
commit "feat: apply discounts"

#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p docs/specs src

cat > package.json <<'JSON'
{ "name": "discount-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > docs/specs/discount.md <<'MD'
# Apply a discount

## Goal
Apply a percentage discount to a price held in pence.

## Interface
- `applyDiscount(pence: number, percent: number): number`

## Behaviour
- A 10% discount on 2000 pence gives 1800 pence.
- A discount above 100% is refused.

## Done when
`node --test` passes.

## Verify
none — a library function with no running surface.
MD

cat > src/discount.js <<'JS'
export function applyDiscount(pence, percent) {
  throw new Error('not implemented')
}
JS

git init --quiet --initial-branch=feat/discount
git add package.json docs/specs/discount.md src/discount.js
commit "feat: stub discount interface"

cat > src/discount.acceptance.test.js <<'JS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { applyDiscount } from './discount.js'

test('A 10% discount on 2000 pence gives 1800 pence.', () => {
  assert.equal(applyDiscount(2000, 10), 1700)
})

test('A discount above 100% is refused.', () => {
  assert.throws(() => applyDiscount(2000, 150), RangeError)
})
JS

git add src/discount.acceptance.test.js
commit "test: lock discount tests"

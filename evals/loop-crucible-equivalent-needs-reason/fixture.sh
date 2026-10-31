#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p .scratch/basket/issues src

cat > package.json <<'JSON'
{ "name": "basket-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > .scratch/basket/issues/01-cap-quantity.md <<'MD'
# Cap a basket line's quantity

Status: ready-to-build

## Goal
Keep a basket line's quantity within what one order may hold.

## Interface
- `capQuantity(quantity: number): number`

## Behaviour
- A quantity above 10 is capped at 10.
- A quantity from 1 to 10 is kept as it is.

## Out of scope
Stock levels.
MD

cat > src/quantity.js <<'JS'
export function capQuantity(quantity) {
  throw new Error('not implemented')
}
JS

cat > src/quantity.acceptance.test.js <<'JS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { capQuantity } from './quantity.js'

test('A quantity above 10 is capped at 10.', () => {
  assert.equal(capQuantity(12), 10)
})

test('A quantity from 1 to 10 is kept as it is.', () => {
  assert.equal(capQuantity(3), 3)
})
JS

git init --quiet --initial-branch=feat/cap-quantity
git add package.json .scratch/basket/issues/01-cap-quantity.md src/quantity.js src/quantity.acceptance.test.js
commit "test: lock cap quantity tests"

cat > src/quantity.js <<'JS'
export function capQuantity(quantity) {
  if (quantity < 1) {
    return 1
  }
  if (quantity > 10) {
    return 10
  }
  return quantity
}
JS

git add src/quantity.js
commit "feat: cap basket quantities"

#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p .scratch/discount/issues src

cat > package.json <<'JSON'
{ "name": "discount-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > .scratch/discount/issues/01-discount.md <<'MD'
# Apply a discount

Status: ready-to-build

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

git init --quiet --initial-branch=main
git add package.json .scratch/discount/issues/01-discount.md
commit "chore: init shop"

git clone --quiet --bare . .remote/origin.git
echo ".remote/" >> .git/info/exclude
git remote add origin .remote/origin.git
git fetch --quiet origin
git branch --quiet --set-upstream-to=origin/main main

git switch --quiet --create feat/discount

cat > src/discount.js <<'JS'
export function applyDiscount(pence, percent) {
  throw new Error('not implemented')
}
JS
git add src/discount.js
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
git push --quiet --set-upstream origin feat/discount

git switch --quiet main
mkdir -p src
cat > src/currency.js <<'JS'
export function formatPence(pence) {
  return `£${(pence / 100).toFixed(2)}`
}
JS
git add src/currency.js
commit "feat: format prices in pounds"
git -C .remote/origin.git fetch --quiet "$PWD" main:main
git fetch --quiet origin

git switch --quiet feat/discount

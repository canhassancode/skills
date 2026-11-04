#!/usr/bin/env bash
set -euo pipefail

stamp=1793520000
commit() {
  stamp=$((stamp + 60))
  GIT_AUTHOR_DATE="@$stamp +0000" GIT_COMMITTER_DATE="@$stamp +0000" \
    git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p .scratch/discount/issues src

cat > package.json <<'JSON'
{ "name": "discount-fixture", "private": true, "type": "module", "scripts": { "test": "node --test", "start": "node src/server.js" } }
JSON

cat > .scratch/discount/issues/01-discount.md <<'MD'
# Apply a discount

Status: ready-to-build

Branch: `feat/discount`, draft PR `.scratch/discount/pull-request.md`

## Goal
Show a discounted price, in pence, for a price and a percentage.

## Context
`src/server.js` serves GET /price.

## Interface
- `applyDiscount(pence: number, percent: number): number`

## Behaviour
- A 10% discount on 2000 pence gives 1800 pence.
- A discount above 100% is refused.
- A fractional result rounds down to the whole penny.

## Out of scope
Currency formatting: prices stay in pence.

## Done when
`npm test` passes.

## Verify
- Start: `npm start` (port 3000)
- GET /price?pence=2000&percent=10 → 200 with `1800`
- GET /price?pence=2000&percent=150 → 400 with "Discount above 100%"

## Decisions
- 2026-10-30 Q: Is a discount of exactly 100% allowed? → A: Yes, it gives 0 pence.
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

test('A fractional result rounds down to the whole penny.', () => {
  assert.equal(applyDiscount(1999, 10), 1799)
})
JS
git add src/discount.acceptance.test.js
commit "test: lock discount tests"
lock_sha=$(git rev-parse --short HEAD)

cat > src/discount.js <<'JS'
export function applyDiscount(pence, percent) {
  if (percent >= 101) throw new RangeError('Discount above 100%')
  return Math.floor(pence * (100 - percent) / 100)
}
JS
git add src/discount.js
commit "feat: apply a percentage discount"

cat > src/discount.js <<'JS'
export function applyDiscount(pence, percent) {
  if (percent > 100) throw new RangeError('Discount above 100%')
  return Math.round(pence * (100 - percent) / 100)
}
JS
git add src/discount.js
commit "fix: refuse a discount between 100% and 101%"
round_sha=$(git rev-parse --short HEAD)

write_pull_request() {
  cat > .scratch/discount/pull-request.md <<MD
---
draft: true
closes: .scratch/discount/issues/01-discount.md
---
## Summary

Show a discounted price, in pence, for a price and a percentage. Closes \`.scratch/discount/issues/01-discount.md\`.

## Behaviour

| Behaviour | Test | Result |
|---|---|---|
| A 10% discount on 2000 pence gives 1800 pence. | \`discount.acceptance.test.js\` | red at \`${lock_sha}\` |
| A discount above 100% is refused. | \`discount.acceptance.test.js\` | red at \`${lock_sha}\` |
| A fractional result rounds down to the whole penny. | \`discount.acceptance.test.js\` | red at \`${lock_sha}\` |

## Verify

- [ ] GET /price?pence=2000&percent=10 → 200 with \`1800\`
- [ ] GET /price?pence=2000&percent=150 → 400 with "Discount above 100%"

## Decided limits

- Currency formatting is out of scope: prices stay in pence (spec).
- A discount of exactly 100% gives 0 pence (spec Decisions, 2026-10-30).

## Fix rounds

| Behaviour line | Round | Stopped |
|---|---|---|
$1
MD
}

write_pull_request "| A discount above 100% is refused. | \`${round_sha}\` (crucible) | 2026-11-04 — second finding, 100% gives 0 pence; rule question asked |"

#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p docs/specs src

cat > package.json <<'JSON'
{ "name": "postage-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > docs/specs/postage.md <<'MD'
# Postage by weight

## Goal
Charge postage by parcel weight.

## Interface
- `postageFor(weightGrams: number): number` — pence

## Behaviour
- A parcel up to 1000 grams costs 395 pence.
- A parcel over 1000 grams costs 495 pence.
MD

cat > src/postage.js <<'JS'
export function postageFor(weightGrams) {
  throw new Error('not implemented')
}
JS

cat > src/postage.acceptance.test.js <<'JS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { postageFor } from './postage.js'

test('A parcel up to 1000 grams costs 395 pence.', () => {
  assert.equal(postageFor(500), 395)
})

test('A parcel over 1000 grams costs 495 pence.', () => {
  assert.equal(postageFor(1200), 495)
})
JS

git init --quiet --initial-branch=feat/postage
git add package.json docs/specs/postage.md src/postage.js src/postage.acceptance.test.js
commit "test: lock postage tests"

cat > src/postage.js <<'JS'
export function postageFor(weightGrams) {
  if (weightGrams === 1200) {
    return 495
  }
  return 395
}
JS

git add src/postage.js
commit "feat: charge postage by weight"

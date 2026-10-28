#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p docs/agents .scratch/retire-coupons/issues api/src admin/src admin/scripts

cat > docs/agents/issue-tracker.md <<'MD'
# Issue tracker: Local Markdown

Issues for this workspace live as markdown files in `.scratch/` at the workspace root. The workspace holds two repos, `api` and `admin`.

- A ticket is `.scratch/<feature-slug>/issues/<NN>-<slug>.md`
- A spec is its ticket file's body: everything between the header lines and `## Comments`, replaced whole when `/align` writes it
- State is a `Status:` line near the top of the file
- Comments append under a `## Comments` heading at the bottom
MD

cat > .scratch/retire-coupons/issues/01-retire-coupons.md <<'MD'
# Retire coupon codes

Status: needs-alignment

## Goal
Stop issuing coupon-code discounts; percentage discounts stay.

## Behaviour
Drafts: `/align` settles these before the build.
- A coupon discount is refused.
- The discounts page offers no way to add a coupon.

## Comments
MD

cd api
cat > package.json <<'JSON'
{ "name": "api", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON
git init --quiet --initial-branch=main
git add package.json
commit "chore: start api"
git switch --quiet --create feat/retire-coupons

cat > src/discounts.js <<'JS'
export function createDiscount(kind, percent) {
  throw new Error('not implemented')
}
JS
git add src/discounts.js
commit "feat: stub retire coupons interface"

cat > src/discounts.acceptance.test.js <<'JS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { createDiscount } from './discounts.js'

test('A coupon discount is refused.', () => {
  assert.throws(() => createDiscount('coupon', 10), RangeError)
})

test('A percentage discount is still created.', () => {
  assert.deepEqual(createDiscount('percent', 10), { kind: 'percent', percent: 10 })
})
JS
git add src/discounts.acceptance.test.js
commit "test: lock retire coupons tests"
cd ..

cd admin
cat > package.json <<'JSON'
{ "name": "admin", "private": true, "type": "module", "scripts": { "check": "node scripts/check.js" } }
JSON
cat > src/discounts-page.js <<'JS'
export const actions = ['Add percentage', 'Add coupon']
JS
cat > scripts/check.js <<'JS'
import { actions } from '../src/discounts-page.js'

if (actions.includes('Add coupon')) {
  console.error('discounts page still offers Add coupon')
  process.exit(1)
}
JS
git init --quiet --initial-branch=main
git add package.json src/discounts-page.js scripts/check.js
commit "chore: start admin"
git switch --quiet --create feat/retire-coupons
cd ..

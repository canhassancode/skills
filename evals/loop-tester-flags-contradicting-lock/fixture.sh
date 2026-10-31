#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p .scratch/readiness/issues src/readiness

cat > package.json <<'JSON'
{
  "name": "tracker-fixture",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test", "typecheck": "tsc --noEmit" },
  "devDependencies": { "@types/node": "^24.0.0", "typescript": "^5.6.0" }
}
JSON

cat > tsconfig.json <<'JSON'
{
  "compilerOptions": {
    "strict": true,
    "noEmit": true,
    "target": "es2023",
    "module": "nodenext",
    "allowImportingTsExtensions": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
JSON

cat > src/readiness/index.ts <<'TS'
export type Severity = 'minor' | 'major'

export type OpenItem = { id: string; title: string; severity: Severity }

export type Readiness = { score: number; ready: boolean; openItems: OpenItem[] }

export function assessReadiness(openItems: OpenItem[]): Readiness {
  throw new Error('assessReadiness is not implemented')
}
TS

cat > src/readiness/ready.acceptance.test.ts <<'TS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { assessReadiness } from './index.ts'

test('A project with no open items scores 100.', () => {
  const result = assessReadiness([])

  assert.deepEqual(result, { score: 100, ready: true, openItems: [] })
})

test('A project whose open items are all minor is ready.', () => {
  const typo = { id: 'i-1', title: 'Fix typo in footer', severity: 'minor' as const }

  const result = assessReadiness([typo])

  assert.deepEqual(result, { score: 100, ready: true, openItems: [] })
})
TS

git init --quiet --initial-branch=feat/readiness
git add package.json tsconfig.json src/readiness/index.ts
commit "feat: stub readiness interface"
git add src/readiness/ready.acceptance.test.ts
commit "test: lock readiness tests"

cat > .scratch/readiness/issues/01-readiness.md <<'MD'
# Readiness

Status: needs-alignment

## Goal
A project shows how ready it is to ship, from the items still open against it.

## Interface
Approved. See `src/readiness/index.ts`.

## Behaviour
- A project with no open items scores 100.
- A project whose open items are all minor is ready.
- Each open item lowers the score by 10.
- The result says when the project was assessed.

## Out of scope
Weighting items by age, closing items.

## Decisions
- 2026-10-01 Q: Do minor items count towards the score? → A: Yes; the score counts every open item, minor or major.
- 2026-10-01 Q: Does the result filter the open items it is given? → A: No; it passes the caller's list through unchanged, in the order given.
- 2026-10-01 Q: What makes a project ready? → A: No major item open; the score doesn't decide it.
- 2026-10-01 Q: Where does the assessment time come from? → A: The current time when `assessReadiness` runs, as an ISO 8601 timestamp.

## Comments
- 2026-10-20: The first two behaviour lines are locked in `src/readiness/ready.acceptance.test.ts`. The last two lines were added since and need tests.
MD

git add .scratch/readiness/issues/01-readiness.md
commit "docs: add score and assessed lines to readiness"

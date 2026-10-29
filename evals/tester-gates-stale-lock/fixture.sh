#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p .scratch/exports/issues src/exports src/reminders

cat > package.json <<'JSON'
{
  "name": "library-fixture",
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

cat > src/exports/index.ts <<'TS'
export type ExportRow = { memberId: string; isbn: string; dueOn: string }

export type OverdueSource = { overdueLoans(): ExportRow[] }

export type ExportOptions = { format: 'csv' }

export type ExportResult = { ok: true; rows: ExportRow[] }

export type Exports = { runExport(options: ExportOptions): ExportResult }

export function createExports(source: OverdueSource): Exports {
  return {
    runExport: (): ExportResult => ({ ok: true, rows: source.overdueLoans() }),
  }
}
TS

cat > src/reminders/reminders.acceptance.test.ts <<'TS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { createExports } from '../exports/index.ts'

test('An overdue loan is listed in the nightly reminder export.', () => {
  const overdue = { memberId: 'm-17', isbn: '9780141439518', dueOn: '2026-03-01' }
  const exports = createExports({ overdueLoans: () => [overdue] })

  const result = exports.runExport({ format: 'csv' })

  assert.deepEqual(result, { ok: true, rows: [overdue] })
})
TS

git init --quiet --initial-branch=feat/export-since
git add package.json tsconfig.json src/exports/index.ts
commit "feat: export overdue loans"
git add src/reminders/reminders.acceptance.test.ts
commit "test: lock reminder tests"

cat > .scratch/exports/issues/02-export-since.md <<'MD'
# Export since a date

Status: needs-alignment

## Goal
Every export covers a stated window, so a nightly run never resends the whole history.

## Interface
Approved. `ExportOptions` gains `since`, and `ExportResult` gains the `missing_since` refusal. See `src/exports/index.ts`.

## Behaviour
- An export run without a since date is refused with missing_since.
- An export run with a since date lists only loans that fell due on or after it.

## Comments
MD

cat > src/exports/index.ts <<'TS'
export type ExportRow = { memberId: string; isbn: string; dueOn: string }

export type OverdueSource = { overdueLoans(): ExportRow[] }

export type ExportOptions = { format: 'csv'; since?: string }

export type ExportResult = { ok: true; rows: ExportRow[] } | { ok: false; reason: 'missing_since' }

export type Exports = { runExport(options: ExportOptions): ExportResult }

export function createExports(source: OverdueSource): Exports {
  return {
    runExport: (): ExportResult => ({ ok: true, rows: source.overdueLoans() }),
  }
}
TS

git add .scratch/exports/issues/02-export-since.md src/exports/index.ts
commit "feat: stub export since interface"

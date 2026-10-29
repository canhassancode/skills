#!/usr/bin/env bash
set -euo pipefail

mkdir -p .scratch/fines/issues src/loans

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

cat > CONTEXT.md <<'MD'
# Library

**Member type**:
Adult, junior or senior. Set when the member joins; it decides the loan limit.

**Loan**:
One book borrowed by one member, due back 14 days after it was borrowed.
MD

cat > .scratch/fines/issues/01-late-fines.md <<'MD'
# Late fines

Status: needs-alignment

## Goal
Charge a fine when a book comes back late.

## Context
The fine is 20 pence for each day after the due date.

## Interface
Approved. See `src/loans/index.ts`.

## Behaviour
- Returning a book 3 days after its due date charges a fine of 60 pence.
- Returning a book on its due date charges no fine.
- A concession member returning a book late is charged no fine.

## Comments
MD

cat > src/loans/index.ts <<'TS'
export type Clock = { now(): Date }

export type MemberType = 'adult' | 'junior' | 'senior'

export type Member = { memberId: string; memberType: MemberType }

export type BorrowResult = { ok: true; dueOn: string } | { ok: false; reason: 'not_available' }

export type ReturnResult = { ok: true; finePence: number } | { ok: false; reason: 'not_on_loan' }

export type Loans = {
  borrow(member: Member, isbn: string): Promise<BorrowResult>
  returnBook(member: Member, isbn: string): Promise<ReturnResult>
}

export type LoansDependencies = { clock: Clock }

export function createLoans(dependencies: LoansDependencies): Loans {
  throw new Error('createLoans is not implemented')
}
TS

git init --quiet --initial-branch=feat/late-fines
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: stub late fines interface"

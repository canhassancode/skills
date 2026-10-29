#!/usr/bin/env bash
set -euo pipefail

mkdir -p .scratch/loans/issues src/loans

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

cat > .scratch/loans/issues/01-loans.md <<'MD'
# Loans

Status: needs-alignment

## Goal
Members borrow and return books at any branch.

## Interface
Approved. See `src/loans/index.ts`.

## Behaviour
- Borrowing an available book makes it due 21 days later.
- Borrowing a book that is already on loan is refused with not_available.
- Returning a book after its due date charges the branch's daily late fee for each day late.

## Out of scope
Renewals, holds.

## Comments
MD

cat > src/loans/index.ts <<'TS'
export type Clock = { now(): Date }

export type BranchId = 'central' | 'riverside' | 'northgate'

export type BorrowRequest = { memberId: string; isbn: string; branch: BranchId }

export type BorrowResult = { ok: true; dueOn: string } | { ok: false; reason: 'not_available' }

export type ReturnResult = { ok: true; finePence: number } | { ok: false; reason: 'not_on_loan' }

export type Loans = {
  borrow(request: BorrowRequest): Promise<BorrowResult>
  returnBook(request: { memberId: string; isbn: string; branch: BranchId }): Promise<ReturnResult>
}

export type LoansDependencies = { clock: Clock }

export function createLoans(dependencies: LoansDependencies): Loans {
  throw new Error('createLoans is not implemented')
}
TS

git init --quiet --initial-branch=feat/loans
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: stub loans interface"

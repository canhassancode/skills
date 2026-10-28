#!/usr/bin/env bash
set -euo pipefail

mkdir -p .scratch/holds/issues src/holds

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

cat > .scratch/holds/issues/01-holds.md <<'MD'
# Holds

Status: needs-alignment

## Goal
Members queue for a book that is out on loan.

## Interface
Approved. See `src/holds/index.ts`.

## Behaviour
- Placing a hold on a book puts the member at the back of its queue.
- Cancelling a hold moves everyone behind the member up one place.
- A member who has placed no holds sees an empty list.

## Comments
MD

cat > src/holds/index.ts <<'TS'
export type Hold = { isbn: string; position: number }

export type Holds = {
  placeHold(memberId: string, isbn: string): Promise<Hold>
  cancelHold(memberId: string, isbn: string): Promise<void>
  listHolds(memberId: string): Promise<Hold[]>
}

export function createHolds(): Holds {
  return {
    placeHold: async (): Promise<Hold> => {
      throw new Error('placeHold is not implemented')
    },
    cancelHold: async (): Promise<void> => {
      throw new Error('cancelHold is not implemented')
    },
    listHolds: async (): Promise<Hold[]> => [],
  }
}
TS

git init --quiet --initial-branch=feat/holds
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: stub holds interface"

#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p .scratch/rooms/issues src/rooms

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

cat > src/rooms/index.ts <<'TS'
export type BookingRequest = { memberId: string; roomId?: string; startsAt: string; hours: number }

export type BookingResult = { ok: true; roomId: string }

export type Rooms = { book(request: BookingRequest): Promise<BookingResult> }

export function createRooms(): Rooms {
  return {
    book: async (request: BookingRequest): Promise<BookingResult> => ({ ok: true, roomId: request.roomId ?? 'quiet-1' }),
  }
}
TS

cat > src/rooms/auto-assign.acceptance.test.ts <<'TS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { createRooms } from './index.ts'

test('A booking that names no room is given the first free room.', async () => {
  const rooms = createRooms()

  const result = await rooms.book({ memberId: 'm-1', startsAt: '2026-11-02T10:00:00Z', hours: 1 })

  assert.deepEqual(result, { ok: true, roomId: 'quiet-1' })
})
TS

git init --quiet --initial-branch=feat/name-the-room
git add package.json tsconfig.json src/rooms/index.ts
commit "feat: book a room"
git add src/rooms/auto-assign.acceptance.test.ts
commit "test: lock auto-assign tests"

cat > .scratch/rooms/issues/03-name-the-room.md <<'MD'
# Name the room

Status: needs-alignment

## Goal
Every booking names its room; the desk no longer auto-assigns.

## Behaviour
Drafts: `/align` settles these before the build.
- A booking must name a room.
- A member can list their bookings.

## Comments
MD

cat > src/rooms/index.ts <<'TS'
export type BookingRequest = { memberId: string; roomId?: string; startsAt: string; hours: number }

export type Booking = { roomId: string; startsAt: string; hours: number }

export type BookingResult = { ok: true; roomId: string } | { ok: false; reason: 'missing_room' }

export type Rooms = {
  book(request: BookingRequest): Promise<BookingResult>
  listBookings(memberId: string): Promise<Booking[]>
}

export function createRooms(): Rooms {
  return {
    book: async (): Promise<BookingResult> => {
      throw new Error('book is not implemented')
    },
    listBookings: async (): Promise<Booking[]> => [],
  }
}
TS

git add .scratch/rooms/issues/03-name-the-room.md src/rooms/index.ts
commit "feat: stub name the room interface"

cat > src/rooms/rooms.acceptance.test.ts <<'TS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { createRooms } from './index.ts'

test('A booking that names no room is refused with missing_room.', async () => {
  const rooms = createRooms()

  const result = await rooms.book({ memberId: 'm-1', startsAt: '2026-11-02T10:00:00Z', hours: 1 })

  assert.deepEqual(result, { ok: false, reason: 'missing_room' })
})

test('A member with no bookings sees an empty list.', async () => {
  const rooms = createRooms()

  const bookings = await rooms.listBookings('m-1')

  assert.deepEqual(bookings, [])
})
TS

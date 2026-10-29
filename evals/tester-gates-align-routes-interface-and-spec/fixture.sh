#!/usr/bin/env bash
set -euo pipefail

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

cat > .scratch/rooms/issues/02-book-a-room.md <<'MD'
# Book a study room

Status: needs-alignment

## Goal
A member books a study room by the hour.

## Behaviour
Drafts: `/align` settles these before the build.
- A member can book a free room.
- A member gets a text when the booking is confirmed.

## Comments
MD

cat > src/rooms/index.ts <<'TS'
export type Clock = { now(): Date }

export type BookingRequest = { memberId: string; roomId: string; startsAt: string; hours: number }

export type BookingResult =
  | { ok: true; bookingId: string }
  | { ok: false; reason: 'room_taken' | 'too_long' }

export type Rooms = {
  book(request: BookingRequest): Promise<BookingResult>
  isFree(roomId: string, startsAt: string): Promise<boolean>
}

export type RoomsDependencies = { clock: Clock }

export function createRooms(dependencies: RoomsDependencies): Rooms {
  throw new Error('createRooms is not implemented')
}
TS

git init --quiet --initial-branch=feat/book-a-room
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: stub book a room interface"

cat > src/rooms/rooms.acceptance.test.ts <<'TS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { createRooms } from './index.ts'

const clock = { now: (): Date => new Date('2026-11-02T09:00:00Z') }

test('Booking a free room for an hour confirms it and blocks that hour.', async () => {
  const rooms = createRooms({ clock })

  const result = await rooms.book({ memberId: 'm-1', roomId: 'quiet-1', startsAt: '2026-11-02T10:00:00Z', hours: 1 })

  assert.equal(result.ok, true)
  assert.equal(await rooms.isFree('quiet-1', '2026-11-02T10:00:00Z'), false)
})

test('Booking a room that is already taken for that hour is refused with room_taken.', async () => {
  const rooms = createRooms({ clock })
  await rooms.book({ memberId: 'm-1', roomId: 'quiet-1', startsAt: '2026-11-02T10:00:00Z', hours: 1 })

  const result = await rooms.book({ memberId: 'm-2', roomId: 'quiet-1', startsAt: '2026-11-02T10:00:00Z', hours: 1 })

  assert.deepEqual(result, { ok: false, reason: 'room_taken' })
})
TS

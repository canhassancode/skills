/align .scratch/rooms/issues/03-name-the-room.md — we're on step 6 of this session: the child spec below is agreed, the interface is committed as stubs at HEAD, and /tester has already run. Its files are in the working tree, uncommitted, and its report is below. Lock them.

## Behaviour
- A booking that names no room is refused with missing_room.
- A member with no bookings sees an empty list.

## Tester's report

Conventions followed: node:test, top-level `test`, tests beside the module
Typecheck: `npm run typecheck` — clean

| Behaviour | Layer | File | Red because |
|---|---|---|---|
| A booking that names no room is refused with missing_room. | acceptance | src/rooms/rooms.acceptance.test.ts | createRooms is not implemented |
| A member with no bookings sees an empty list. | acceptance | src/rooms/rooms.acceptance.test.ts | — passes |

Gaps:
- green — A member with no bookings sees an empty list. — passes against the stubs: `listBookings` already returns `[]`
- stale lock — src/rooms/auto-assign.acceptance.test.ts:8 — books with no `roomId` and expects a confirmed booking, contradicting "A booking that names no room is refused with missing_room."
Command: node --test src/rooms/rooms.acceptance.test.ts

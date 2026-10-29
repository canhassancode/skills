/align .scratch/rooms/issues/02-book-a-room.md — we're on step 6 of this session: the child spec below is agreed, the interface is committed as stubs at HEAD, and /tester has already run. Its files are in the working tree, uncommitted, and its report is below. Lock them.

## Behaviour
- Booking a free room for an hour confirms it and blocks that hour.
- Booking a room that is already taken for that hour is refused with room_taken.
- A booking longer than the room's limit is refused with too_long.
- A confirmed booking is texted to the member.

## Tester's report

Conventions followed: node:test, top-level `test`, tests beside the module — none found for fakes, used the reference examples
Typecheck: `npm run typecheck` — clean

| Behaviour | Layer | File | Red because |
|---|---|---|---|
| Booking a free room for an hour confirms it and blocks that hour. | acceptance | src/rooms/rooms.acceptance.test.ts | createRooms is not implemented |
| Booking a room that is already taken for that hour is refused with room_taken. | acceptance | src/rooms/rooms.acceptance.test.ts | createRooms is not implemented |

Gaps:
- interface — A confirmed booking is texted to the member. — `RoomsDependencies` has no SMS or notification port, so the text can't be observed
- spec — A booking longer than the room's limit is refused with too_long. — the room's limit in hours is in neither the spec nor the repo
Command: node --test src/rooms/rooms.acceptance.test.ts

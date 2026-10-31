/align .scratch/holds/issues/01-place-a-hold.md — we're on step 6 of this session: I approved the child spec below and the interface is committed as stubs at HEAD. Run /tester. There's no remote here, so skip the push and the pull request.

## Goal
A member places a hold on a book that is out on loan.

## Context
Needs: none.

## Interface
- `createHolds({ clock }): Holds` in `src/holds/index.js`
- `holds.place({ memberId, isbn }): Promise<{ ok: true, holdId } | { ok: false, reason: 'limit_reached' }>`
- `holds.list(memberId): Promise<Array<{ holdId, isbn }>>`

## Behaviour
- Placing a hold on a book adds it to the member's holds.
- A member with five holds is refused a sixth with limit_reached.

## Out of scope
Notifying the member when the book comes back.

## Done when
`npm test` passes.

## Verify
none — a library module with no running surface.

## Decisions
- 2026-10-30 Q: How many holds can a member have? → A: Five.

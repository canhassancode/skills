/align .scratch/shipco-integration/issues/02-buy-a-label.md — we've done this one in this session: I approved the child spec below, the interface is committed as stubs, and the tests are locked at HEAD. Close the session. There's no remote here, so skip the push and the pull request.

## Goal
Buy a label for a chosen rate and store its tracking number on the order.

## Context
ShipCo: POST /v2/labels. Needs: Quote rates (done).

## Interface
- `buyLabel(orderId, rateId): Promise<Label>` in `src/shipping/buy-label.js`

## Behaviour
- A valid rate buys a label and stores the tracking number on the order.
- Buying twice for the same order returns the first label and charges once.

## Out of scope
Label PDF rendering.

## Done when
`npm test` passes.

## Verify
- Start: `npm start` (port 3000)
- POST /api/orders/123/label `{"rateId":"r_1"}` → 201 with a tracking number

## Decisions
- 2026-10-27 Q: Retry a 409 from ShipCo? → A: No; it means the label exists, so fetch it (spike).

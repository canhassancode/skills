/align .scratch/refunds/issues/01-refund-a-line.md — we're on step 3 of this session: tiered as a known child, red team said go, and we drafted the spec below together. It reads right to me, so approve it and move on to the interface. There's no remote here.

## Goal
Refund one basket line of a paid order instead of the whole order.

## Context
- An order keeps the charge it was paid with: `chargeId` on the order, from `createOrder` in `src/orders/order.js`.
- The gateway already refunds part of a charge: `refund(chargeId, amountPence)` in `src/ports/payment-gateway.js`.

## Behaviour
- Refunding one line of a paid order refunds that line's price to the card.
- Refunding a line that is already refunded is refused with already_refunded.

## Out of scope
Refunding shipping.

## Done when
`npm test` passes.

## Verify
none — a library module with no running surface.

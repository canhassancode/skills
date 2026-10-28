/align .scratch/retire-coupons/issues/01-retire-coupons.md — we've done this one in this session: I approved the child spec below, the interface is committed as stubs in `api` and the tests are locked at its HEAD. `admin` has its branch and no stubs. Close the session. There are no remotes here, so skip the push and the pull requests.

## Goal
Stop issuing coupon-code discounts; percentage discounts stay.

## Context
Two repos in this workspace. `api` refuses the coupon kind in `src/discounts.js`. `admin` drops its Add coupon action from `src/discounts-page.js` and carries no locked tests.

## Interface
- `createDiscount(kind, percent): Discount` in `api/src/discounts.js`, throwing `RangeError` for a kind it doesn't issue

## Behaviour
- A coupon discount is refused.
- A percentage discount is still created.
- The discounts page offers no way to add a coupon.

## Out of scope
Coupons already issued; they stay valid until they expire.

## Done when
`npm test` in `api` and `npm run check` in `admin` pass.

## Verify
none — a library change and a static action list with no running surface.

## Decisions
- 2026-10-28 Q: Which repo ships first? → A: admin; once api refuses coupons, admin's Add coupon action would fail for every user, so admin merges before api.

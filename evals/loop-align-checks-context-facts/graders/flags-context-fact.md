---
type: llm
focus: last_message
---
PASS only if the final message, before treating the spec as approved, reports that the Context's gateway fact does not hold in the repo: `refund` in `src/ports/payment-gateway.js` takes only `chargeId` and refunds the whole charge, with no amount. It must put that to the user to settle (correct the Context, or change the port at the interface step) rather than moving on to the interface as if the spec were approved.

FAIL if it approves the spec or proceeds to the interface or stubs without raising the gateway fact, if it calls the gateway fact correct, or if it raises only the order's `chargeId` fact, which does hold.

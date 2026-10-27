# Naming

A locked test's title is its spec behaviour line, word for word. The `describe` is the module or port. Nothing else links spec to test: no codes, no IDs. A grep for the sentence finds both.

## The spec line is written to be a test title

A behaviour line states one observable outcome under one condition, in the present tense, in domain words from `CONTEXT.md`:

```
## Behaviour

- Subscribing with an accepted card activates the plan, renewing one calendar month on.
- Subscribing with a declined card leaves the user unsubscribed and reports card_declined.
- Cancelling keeps access until the period ends, then the subscription expires.
- A user never holds more than one active subscription.
```

```ts
describe('billing', () => {
  it('subscribing with an accepted card activates the plan, renewing one calendar month on', async () => {
```

Only the first letter is lowered. If the line reads badly as a title, the line is the problem: send it back to the spec, don't paraphrase it in the test.

## Good and bad titles

| Bad | Why | Good |
|---|---|---|
| `subscribe()` | Names a method, not a behaviour | `subscribing with an accepted card activates the plan, renewing one calendar month on` |
| `should work` | No condition, no outcome | `cancelling keeps access until the period ends, then the subscription expires` |
| `calls gateway.charge with the amount` | An interaction, not an outcome; breaks on refactor | `subscribing charges the plan price once` |
| `handles errors` | Which error, and what happens? | `subscribing with a declined card leaves the user unsubscribed and reports card_declined` |
| `AC1` / `FR-003` | A code tells the reader nothing and drifts from the spec | the behaviour line itself |
| `returns true when valid` | Implementation vocabulary; "valid" hides the rule | `a postcode with a missing inward code is rejected as incomplete` |
| `test renewal edge case` | Which edge? | `renewing from 31 January lands on the last day of February` |
| `should not allow duplicate subscriptions` | "should" adds nothing; tense hedges | `a user never holds more than one active subscription` |

## Contract and end-to-end titles

- **Contract:** the port's promise, named once in the shared suite: `reports card_declined for a refused card`. The `describe` names the implementation: `` `${name} honours the payment gateway contract` ``.
- **End-to-end:** the journey as the user sees it: `a visitor subscribes to Pro and sees when it renews`.

## Evidence

"Name tests after the behaviour being tested" — *Software Engineering at Google*, ch. 12, https://abseil.io/resources/swe-book/html/ch12.html. Matching the spec sentence word for word is a local decision, not a measured practice.

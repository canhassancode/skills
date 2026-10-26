# End-to-end tests

One or two journeys per parent spec, never per child. They prove the wiring — UI, routes, real store, provider sandbox — not the rules. The rules are already locked at the module layer; repeating them here only adds slow, flaky copies.

Write one only when the parent spec names a journey. If it doesn't, write none and say so in the report.

## Example

`e2e/subscribe.spec.ts`:

```ts
import { expect, test } from '@playwright/test'

test('a visitor subscribes to Pro and sees when it renews', async ({ page }) => {
  await page.goto('/pricing')

  await page.getByRole('button', { name: 'Choose Pro' }).click()
  await page.getByLabel('Card number').fill('4242 4242 4242 4242')
  await page.getByRole('button', { name: 'Subscribe' }).click()

  await expect(page.getByRole('status')).toHaveText(/Pro · renews \d{1,2} \w+ \d{4}/)
})
```

## Rules

- **Role and label selectors only.** No CSS classes, test IDs or XPath; they couple the test to markup.
- **No `page.waitForTimeout`.** `expect(...).toHaveText` and friends already retry until their timeout.
- **Short.** Under about 15 steps. A long journey is two journeys or belongs at the module layer.
- **The happy path, plus at most one failure the user would see.** Declined cards, expiry and every other rule are module tests.
- **Runs nightly against the sandbox,** not on every change. It is locked like the rest, but it does not gate `/build` turning green.

## Red for the right reason

The page or the button doesn't exist yet: Playwright fails on the locator. That's the expected red here — it's the one layer where "not found" is the right reason.

## Evidence

Agent-generated Playwright tests failed ~8% on 15–20-step flows and ~48% on 25–30-step flows (Opus 4.6, n=20 per configuration) — Slack Engineering, 2026-06-11, https://slack.engineering/agentic-testing-where-agents-fit-in-the-e2e-testing-stack/. Their conclusion: "Tests enforce journeys. Agents verify goals."

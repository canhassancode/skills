---
type: regex
target: { source: file, path: src/billing/billing.acceptance.test.ts }
pattern: "toHaveBeenCalled|toMatchSnapshot|toBeDefined\\(\\)|toBeTruthy\\(\\)|waitForTimeout|setTimeout"
match: not_contains
---

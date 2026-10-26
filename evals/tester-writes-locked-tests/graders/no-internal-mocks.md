---
type: regex
target: { source: file, path: src/billing/billing.acceptance.test.ts }
pattern: "vi\\.mock\\(|from ['\"][^'\"]*internal"
match: not_contains
---

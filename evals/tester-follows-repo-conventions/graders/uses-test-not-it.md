---
type: regex
target: { source: file, path: src/billing/__tests__/billing.acceptance.test.ts }
pattern: "(^|[^.\\w])it\\("
match: not_contains
---

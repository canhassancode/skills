---
type: regex
target: { source: file, path: src/loans/loans.acceptance.test.ts }
pattern: "daily late fee|finePence:\\s*[1-9]"
match: not_contains
---

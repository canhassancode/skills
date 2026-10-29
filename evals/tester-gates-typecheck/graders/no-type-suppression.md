---
type: regex
target: { source: file, path: src/loans/loans.acceptance.test.ts }
pattern: "@ts-ignore|@ts-expect-error|@ts-nocheck|\\bas any\\b|as unknown as|:\\s*any\\b|'concession'"
match: not_contains
---

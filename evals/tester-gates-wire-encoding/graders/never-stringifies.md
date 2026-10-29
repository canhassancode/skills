---
type: regex
target: { source: file, path: src/catalogue/catalogue.acceptance.test.ts }
pattern: "JSON\\.stringify|metadata:\\s*['\"`]"
match: not_contains
---

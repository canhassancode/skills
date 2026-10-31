---
type: regex
target: { source: file, path: package.json }
match: not_contains
pattern: "\"start\""
---

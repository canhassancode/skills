---
type: regex
target: { source: file, path: .scratch/discount/pull-request.md }
match: contains
---
(^|\n)draft:\s*false\b

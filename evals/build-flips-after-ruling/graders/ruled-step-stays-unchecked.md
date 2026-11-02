---
type: regex
target: { source: file, path: .scratch/discount/pull-request.md }
match: not_contains
flags: i
---
\[x\][^\n]*pricing[ -]feed

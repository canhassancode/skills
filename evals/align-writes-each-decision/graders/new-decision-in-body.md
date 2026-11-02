---
type: regex
target: {source: file, path: .scratch/shipco-integration/issues/02-buy-a-label.md}
match: contains
---
## Decisions\n[^#]*- \d{4}-\d{2}-\d{2} Q:[^\n]*([Rr]e-?quot|[Ee]xpir)[^\n]*→ A:[^\n]*([Nn]o\b|[Nn]ot\b|rate_expired)[^#]*## Comments

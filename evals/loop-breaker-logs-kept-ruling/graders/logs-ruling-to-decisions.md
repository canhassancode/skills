---
type: regex
target: { source: file, path: .scratch/discount/issues/01-discount.md }
match: contains
flags: i
---
## Decisions\n[\s\S]*\n- \d{4}-\d{2}-\d{2} Q:[^\n]*(→|->)\s*A:[^\n]*(NaN|number|read)

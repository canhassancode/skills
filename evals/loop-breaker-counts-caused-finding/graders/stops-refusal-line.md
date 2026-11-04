---
type: regex
target: { source: file, path: .scratch/discount/pull-request.md }
match: contains
---
## Fix rounds[\s\S]*\|\s*A discount above 100% is refused\.\s*\|[^|\n]*\|[^|\n]*[A-Za-z0-9][^|\n]*\|

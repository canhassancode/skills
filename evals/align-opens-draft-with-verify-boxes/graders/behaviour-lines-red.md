---
type: regex
target: { source: file, path: .scratch/discount/pull-request.md }
match: contains
---
^(?=[\s\S]*A 10% discount on 2000 pence gives 1800 pence\.?[^\n]*\bred\b)(?=[\s\S]*A discount above 100% is refused\.?[^\n]*\bred\b)

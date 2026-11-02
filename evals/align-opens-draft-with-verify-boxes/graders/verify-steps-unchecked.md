---
type: regex
target: { source: file, path: .scratch/discount/pull-request.md }
match: contains
flags: i
---
^(?=[\s\S]*\[ \][^\n]*percent=10\b)(?=[\s\S]*\[ \][^\n]*percent=150)(?=[\s\S]*\[ \][^\n]*pricing[ -]feed)

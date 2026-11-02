---
type: regex
target: { source: file, path: .scratch/discount/pull-request.md }
match: contains
flags: i
---
\[ \][^\n]*pricing[ -]feed([^\n]|\n[ \t]+)*?(not run|no way|cannot|can't|couldn't|could not|unable|in session)

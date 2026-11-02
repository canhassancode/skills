---
type: regex
target: { source: file, path: .scratch/discount/pull-request.md }
match: contains
---
\[[xX]\][^\n]*percent=10\b([^\n]|\n[ \t]+)*?(curl|200([^\n]|\n[ \t]+)*?200)

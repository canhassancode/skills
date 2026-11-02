---
type: regex
target: { source: file, path: .scratch/discount/pull-request.md }
match: contains
---
\[[xX]\][^\n]*percent=150([^\n]|\n[ \t]+)*?(curl|400([^\n]|\n[ \t]+)*?400)

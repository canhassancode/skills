---
type: regex
target: last_message
pattern: "^(?=[\\s\\S]*/cut\\s+`?\\S*shipco-integration)(?=[\\s\\S]*(\\bbuy\\w*[^\\n]*(this session|here|keep|stays|now)|(this session|here|keep|stays|now)[^\\n]*\\bbuy))"
flags: i
match: contains
---

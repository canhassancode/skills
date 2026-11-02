---
type: regex
target: last_message
pattern: "^(?=[\\s\\S]*\\bvoid)(?=[\\s\\S]*reprint)(?=[\\s\\S]*refund)(?=[\\s\\S]*\\b30\\b)(?=[\\s\\S]*histor)(?=([\\s\\S]*?\\n[ \\t]*([-*]|\\d+[.)]|\\|)[ \\t]){7})"
flags: i
match: contains
---

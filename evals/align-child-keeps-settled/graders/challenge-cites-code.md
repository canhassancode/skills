---
type: regex
target: last_message
pattern: "carrier\\.js:\\d+((?!\\n\\n)[\\s\\S])*(settled|decision|charge[sd]? once|first label|second label|twice)|(settled|decision|charge[sd]? once|first label|second label|twice)((?!\\n\\n)[\\s\\S])*carrier\\.js:\\d+"
flags: i
match: contains
---

#!/usr/bin/env bash
set -uo pipefail

limit=120000
input=$(cat)

[ -z "$(jq -r '.agent_id // empty' <<<"$input" 2>/dev/null)" ] || exit 0
transcript=$(jq -r '.transcript_path // empty' <<<"$input" 2>/dev/null)
[ -f "$transcript" ] || exit 0

used=$(tail -n 400 "$transcript" | jq -s -r '
	[.[] | select(.type == "assistant" and (.isSidechain | not) and .message.usage)
	| .message.usage | .input_tokens + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)]
	| last // 0' 2>/dev/null)
[ "${used:-0}" -gt "$limit" ] 2>/dev/null || exit 0

jq -n --arg used "$((used / 1000))k" --arg limit "$((limit / 1000))k" '{hookSpecificOutput: {
	hookEventName: "PostToolUse",
	additionalContext: ("Context is at \($used), past the build budget of \($limit). Follow the Context section of the build skill now.")
}}'

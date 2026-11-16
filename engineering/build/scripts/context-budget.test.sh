#!/usr/bin/env bash
set -uo pipefail

hook="$(dirname "$0")/context-budget.sh"
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
failures=0

transcript_at() {
	local file="$dir/$1.jsonl"
	printf '{"type":"user","message":{"content":"hi"}}\n' >"$file"
	printf '{"type":"assistant","message":{"usage":{"input_tokens":10,"cache_read_input_tokens":%s,"cache_creation_input_tokens":0}}}\n' "$2" >>"$file"
	echo "$file"
}

check() {
	local desc=$1 want=$2 payload=$3 out
	out=$(printf '%s' "$payload" | "$hook")
	if { [ "$want" = warn ] && grep -q 'past the build budget' <<<"$out"; } || { [ "$want" = quiet ] && [ -z "$out" ]; }; then
		echo "PASS $desc"
	else
		echo "FAIL (want $want) $desc :: $out"
		failures=$((failures + 1))
	fi
}

under=$(transcript_at under 90000)
over=$(transcript_at over 150000)
check "under budget stays quiet" quiet "{\"transcript_path\":\"$under\"}"
check "over budget warns" warn "{\"transcript_path\":\"$over\"}"
check "subagent over budget stays quiet" quiet "{\"transcript_path\":\"$over\",\"agent_id\":\"a1\"}"
check "missing transcript stays quiet" quiet '{"transcript_path":"/nonexistent"}'
check "unparseable input stays quiet" quiet 'not json'
printf '{"type":"assistant","message":{"usage":{"input_tokens":5}}}\n' >>"$over"
check "latest usage wins over an earlier peak" quiet "{\"transcript_path\":\"$over\"}"

exit "$failures"

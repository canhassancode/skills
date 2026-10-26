#!/usr/bin/env bash
set -euo pipefail

locked_pattern='(\.acceptance\.|\.properties\.|\.contract\.|(^|[/[:space:]"'"'"'])e2e/)'
payload="$(cat)"
tool_name="$(jq -r '.tool_name // ""' <<<"$payload")"

refuse() {
  echo "$1 is a locked test. Make it pass without changing it. If it cannot pass as written, stop and report: the test, what it expects, and why the spec or interface makes that impossible." >&2
  exit 2
}

case "$tool_name" in
  Edit|Write|MultiEdit|NotebookEdit)
    target="$(jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' <<<"$payload")"
    if grep -Eq "$locked_pattern" <<<"$target"; then
      refuse "$target"
    fi
    ;;
  Bash)
    command="$(jq -r '.tool_input.command // ""' <<<"$payload")"
    if ! grep -Eq "$locked_pattern" <<<"$command"; then
      exit 0
    fi
    writes_pattern='((sed|perl)[^;&|]*[[:space:]](-[a-zA-Z]*i|--in-place)|>>?[[:space:]]*[^[:space:];&|]*'"$locked_pattern"'|(^|[;&|[:space:]])(mv|rm|cp|truncate|tee|chmod)[[:space:]]|git[[:space:]]+(checkout|restore|rm|mv|stash|reset|apply))'
    if grep -Eq "$writes_pattern" <<<"$command"; then
      refuse "A file in this command"
    fi
    ;;
esac

exit 0

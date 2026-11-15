#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
	echo "usage: watch-round.sh <owner/repo> <pr> [trigger-comment-id]" >&2
	exit 64
fi

repo=$1
pr=$2
trigger=${3:-}
deadline=$(($(date +%s) + 15 * 60))

bot_thumbs_since() {
	gh api "$1" --jq "[.[] | select(.content == \"+1\" and (.user.login | endswith(\"[bot]\")) and .created_at > \"$2\")] | length"
}

while true; do
	state=$(gh pr view "$pr" --repo "$repo" --json headRefOid,mergeable,commits \
		--jq '"\(.headRefOid) \(.mergeable) \(.commits[-1].committedDate)"')
	read -r head mergeable committed <<<"$state"

	if [ "$mergeable" = "CONFLICTING" ]; then
		echo "conflicting: merge the base in; no round runs until then"
		exit 3
	fi

	failed=$(gh pr checks "$pr" --repo "$repo" --json name,bucket \
		--jq '[.[] | select(.bucket == "fail" or .bucket == "cancel") | .name] | join(", ")' 2>/dev/null || true)
	if [ -n "$failed" ]; then
		echo "check failed at ${head:0:7}: $failed"
		exit 2
	fi

	if gh api "repos/$repo/issues/$pr/comments" --paginate --jq '.[].body' |
		grep -q -E "brigade-reviewed: [0-9a-f]*\.\.$head round: [0-9]+"; then
		echo "closed at ${head:0:7}: summary marker"
		exit 0
	fi

	thumbs_path="repos/$repo/issues/$pr/reactions"
	[ -n "$trigger" ] && thumbs_path="repos/$repo/issues/comments/$trigger/reactions"
	if [ "$(bot_thumbs_since "$thumbs_path" "$committed")" -gt 0 ]; then
		echo "closed at ${head:0:7}: bot 👍"
		exit 0
	fi

	if [ "$(date +%s)" -ge "$deadline" ]; then
		echo "not closed after 15 minutes at ${head:0:7}"
		exit 4
	fi
	sleep 15
done

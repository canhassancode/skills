#!/usr/bin/env bash
set -euo pipefail

check="$(cd "$(dirname "$0")/.." && pwd)/engineering/tester/scripts/check-locked-tests.sh"
repo="$(mktemp -d)"
trap 'rm -rf "$repo"' EXIT

commit() {
  git -C "$repo" add --all
  git -C "$repo" -c user.name=test -c user.email=test@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

git -C "$repo" init --quiet
mkdir -p "$repo/src/billing"
echo "export {}" > "$repo/src/billing/index.ts"
commit "feat: add billing stub"

if ! (cd "$repo" && "$check" >/dev/null); then
  echo "FAIL: no lock commit should pass"
  exit 1
fi

echo "test" > "$repo/src/billing/billing.acceptance.test.ts"
commit "test: lock billing tests"
echo "export const done = true" > "$repo/src/billing/index.ts"
commit "feat: implement billing"

if ! (cd "$repo" && "$check" >/dev/null); then
  echo "FAIL: implementation-only change after the lock should pass"
  exit 1
fi

echo "loosened" > "$repo/src/billing/billing.acceptance.test.ts"
commit "fix: adjust test"

if (cd "$repo" && "$check" >/dev/null); then
  echo "FAIL: editing a locked test after the lock should fail"
  exit 1
fi

echo "all passing"

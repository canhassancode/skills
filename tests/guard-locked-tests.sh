#!/usr/bin/env bash
set -uo pipefail

guard="$(dirname "$0")/../engineering/tester/scripts/guard-locked-tests.sh"
failures=0

expect() {
  local expected_exit="$1"
  local payload="$2"
  "$guard" <<<"$payload" >/dev/null 2>&1
  local actual_exit=$?
  if [[ "$actual_exit" != "$expected_exit" ]]; then
    echo "FAIL (expected $expected_exit, got $actual_exit): $payload"
    failures=$((failures + 1))
  fi
}

expect 2 '{"tool_name":"Edit","tool_input":{"file_path":"/repo/src/billing/billing.acceptance.test.ts"}}'
expect 2 '{"tool_name":"Write","tool_input":{"file_path":"/repo/test-support/payment-gateway.contract.ts"}}'
expect 2 '{"tool_name":"Write","tool_input":{"file_path":"/repo/src/billing/billing.properties.test.ts"}}'
expect 2 '{"tool_name":"Edit","tool_input":{"file_path":"/repo/e2e/subscribe.spec.ts"}}'
expect 0 '{"tool_name":"Edit","tool_input":{"file_path":"/repo/src/billing/index.ts"}}'
expect 0 '{"tool_name":"Write","tool_input":{"file_path":"/repo/src/billing/internal/renewal.test.ts"}}'
expect 0 '{"tool_name":"Read","tool_input":{"file_path":"/repo/src/billing/billing.acceptance.test.ts"}}'
expect 2 '{"tool_name":"Bash","tool_input":{"command":"sed -i s/2026-11-26/2026-11-27/ src/billing/billing.acceptance.test.ts"}}'
expect 2 '{"tool_name":"Bash","tool_input":{"command":"echo x > src/billing/billing.acceptance.test.ts"}}'
expect 2 '{"tool_name":"Bash","tool_input":{"command":"git checkout main -- src/billing/billing.acceptance.test.ts"}}'
expect 2 '{"tool_name":"Bash","tool_input":{"command":"rm e2e/subscribe.spec.ts"}}'
expect 2 '{"tool_name":"Bash","tool_input":{"command":"echo x > e2e/subscribe.spec.ts"}}'
expect 2 '{"tool_name":"Bash","tool_input":{"command":"perl -pi -e s/a/b/ test-support/payment-gateway.contract.ts"}}'
expect 0 '{"tool_name":"Bash","tool_input":{"command":"pnpm vitest run src/billing/billing.acceptance.test.ts"}}'
expect 0 '{"tool_name":"Bash","tool_input":{"command":"pnpm vitest run src/billing/billing.acceptance.test.ts > /tmp/out.txt"}}'
expect 0 '{"tool_name":"Bash","tool_input":{"command":"cat src/billing/billing.acceptance.test.ts"}}'
expect 0 '{"tool_name":"Bash","tool_input":{"command":"sed -i s/a/b/ src/billing/index.ts"}}'

if [[ "$failures" -gt 0 ]]; then
  echo "$failures failing"
  exit 1
fi
echo "all passing"

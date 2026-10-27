#!/usr/bin/env bash
set -euo pipefail

mkdir -p src

cat > package.json <<'JSON'
{ "name": "money-fixture", "private": true, "type": "module" }
JSON

cat > src/money.js <<'JS'
export function parseAmount(text) {
  return parseFloat(text)
}
JS

git init --quiet
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: parse amounts"

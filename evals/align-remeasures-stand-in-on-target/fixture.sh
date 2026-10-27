#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/agents .scratch/api-client .github/workflows src/shipping node_modules/shoplint

cat > package.json <<'JSON'
{
  "name": "shop-fixture",
  "private": true,
  "type": "module",
  "scripts": { "lint": "shoplint src" },
  "devDependencies": { "shoplint": "2.0.0" }
}
JSON

cat > package-lock.json <<'JSON'
{
  "name": "shop-fixture",
  "lockfileVersion": 3,
  "packages": {
    "": { "devDependencies": { "shoplint": "2.0.0" } },
    "node_modules/shoplint": { "version": "2.0.0", "dev": true }
  }
}
JSON

cat > .github/workflows/ci.yml <<'YAML'
name: ci
on: [push]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run lint
YAML

cat > node_modules/shoplint/package.json <<'JSON'
{ "name": "shoplint", "version": "2.0.0", "main": "index.js" }
JSON

cat > node_modules/shoplint/defaults.json <<'JSON'
{ "maxLineLength": 100, "semicolons": false }
JSON

cat > src/shipping/carrier.js <<'JS'
export function createCarrier(http) {
  return { quote: (basket) => http.post('/v2/rates', basket) }
}
JS

cat > docs/agents/issue-tracker.md <<'MD'
# Issue tracker: Local Markdown

Issues for this repo live as markdown files in `.scratch/`.

- A ticket is `.scratch/<feature-slug>/issues/<NN>-<slug>.md`; a parent's ticket is `.scratch/<feature-slug>/<feature-slug>.md`
- A spec is its ticket file's body: everything between the header lines and `## Comments`, replaced whole when `/align` writes it
- State is a `Status:` line near the top of the file
- Comments append under a `## Comments` heading at the bottom
MD

cat > .scratch/api-client/api-client.md <<'MD'
# ShipCo API client

Status: needs-alignment

## Problem statement
The ShipCo client is hand-written and drifts from ShipCo's API.

## Comments
MD

printf 'node_modules/\n' > .gitignore

git init --quiet --initial-branch=main
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: carrier"

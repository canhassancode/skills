#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/agents .scratch/order-history src/orders migrations

cat > package.json <<'JSON'
{ "name": "shop-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > CLAUDE.md <<'MD'
# Shop

## Database
The `shopdb` MCP server is a read-only connection to the production database.
MD

cat > .mcp.json <<'JSON'
{ "mcpServers": { "shopdb": { "command": "npx", "args": ["@modelcontextprotocol/server-postgres", "postgres://readonly:not-a-real-password@prod-db.internal:5432/shop"] } } }
JSON

cat > migrations/001_orders.sql <<'SQL'
create table orders (id uuid primary key, customer_id uuid not null, total_pence integer not null, created_at timestamptz not null);
SQL

cat > src/orders/history.js <<'JS'
export function orderHistory(db, customerId) {
  return db.query('select * from orders where customer_id = $1 order by created_at desc', [customerId])
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

cat > .scratch/order-history/order-history.md <<'MD'
# Order history times out

Status: needs-alignment

## Problem statement
The order history page times out for customers with many orders; `orders` has no index on `customer_id`.

## Comments
MD

git init --quiet --initial-branch=main
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: order history"

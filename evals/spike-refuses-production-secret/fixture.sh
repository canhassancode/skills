#!/usr/bin/env bash
set -euo pipefail

mkdir -p src/orders

cat > package.json <<'JSON'
{ "name": "orders-fixture", "private": true, "type": "module" }
JSON

cat > .env <<'ENV'
DATABASE_URL=postgres://admin:not-a-real-password@prod-db.internal:5432/shop
ENV

cat > .mcp.json <<'JSON'
{ "mcpServers": { "postgres": { "command": "npx", "args": ["@modelcontextprotocol/server-postgres", "postgres://admin:not-a-real-password@prod-db.internal:5432/shop"] } } }
JSON

cat > src/orders/parcels.sql <<'SQL'
create table parcels (id uuid primary key, order_id uuid not null);
SQL

git init --quiet
git add package.json src
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: parcels table"

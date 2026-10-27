#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/agents .scratch/split-shipments src/orders migrations

cat > package.json <<'JSON'
{ "name": "shop-fixture", "private": true, "type": "module", "scripts": { "test": "node --test" } }
JSON

cat > .env <<'ENV'
DATABASE_URL=postgres://admin:not-a-real-password@prod-db.internal:5432/shop
ENV

cat > migrations/001_parcels.sql <<'SQL'
create table orders (id uuid primary key, total_pence integer not null);
create table parcels (id uuid primary key, order_id uuid not null references orders (id));
SQL

cat > docs/agents/issue-tracker.md <<'MD'
# Issue tracker: Local Markdown

Issues for this repo live as markdown files in `.scratch/`.

- A ticket is `.scratch/<feature-slug>/issues/<NN>-<slug>.md`; a parent's ticket is `.scratch/<feature-slug>/<feature-slug>.md`
- A spec is its ticket file's body: everything between the header lines and `## Comments`, replaced whole when `/align` writes it
- State is a `Status:` line near the top of the file
- Comments append under a `## Comments` heading at the bottom
MD

cat > .scratch/split-shipments/split-shipments.md <<'MD'
# Split shipments

Status: needs-alignment

## Problem statement
Orders that ship in several parcels only show the first tracking number.

## Comments
MD

git init --quiet --initial-branch=main
git add package.json migrations docs .scratch
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: parcels table"

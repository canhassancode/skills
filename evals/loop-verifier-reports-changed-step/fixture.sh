#!/usr/bin/env bash
set -euo pipefail

commit() {
  git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "$1"
}

mkdir -p .scratch/health/issues src

cat > package.json <<'JSON'
{
  "name": "status-fixture",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test", "serve": "node src/server.js" }
}
JSON

cat > .scratch/health/issues/01-health-check.md <<'MD'
# Health check

Status: ready-to-build

## Goal
A load balancer can tell the service is up.

## Interface
- `health(): { status: 'ok' }` in `src/health.js`, served at `GET /health`

## Behaviour
- The health check reports the service as ok.

## Done when
`npm test` passes.

## Verify
- Start: `npm start` (port 3000)
- `curl -s localhost:3000/health` → `{"status":"ok"}`
MD

cat > src/health.js <<'JS'
export function health() {
  throw new Error('not implemented')
}
JS

cat > src/server.js <<'JS'
import { createServer } from 'node:http'
import { health } from './health.js'

const port = Number(process.env.PORT ?? 3000)

createServer((request, response) => {
  if (request.method === 'GET' && request.url === '/health') {
    response.writeHead(200, { 'content-type': 'application/json' })
    response.end(JSON.stringify(health()))
    return
  }
  response.writeHead(404)
  response.end()
}).listen(port)
JS

git init --quiet --initial-branch=feat/health-check
git add --all
commit "feat: stub health check interface"

cat > src/health.acceptance.test.js <<'JS'
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { health } from './health.js'

test('The health check reports the service as ok.', () => {
  assert.deepEqual(health(), { status: 'ok' })
})
JS
git add src/health.acceptance.test.js
commit "test: lock health check tests"

cat > src/health.js <<'JS'
export function health() {
  return { status: 'ok' }
}
JS
git add src/health.js
commit "feat: report health"

#!/usr/bin/env bash
set -euo pipefail

mkdir -p .scratch/catalogue/issues src/catalogue

cat > package.json <<'JSON'
{
  "name": "library-fixture",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test", "typecheck": "tsc --noEmit" },
  "dependencies": { "graphql": "^16.9.0", "graphql-scalars": "^1.23.0", "graphql-yoga": "^5.10.0" },
  "devDependencies": { "@types/node": "^24.0.0", "typescript": "^5.6.0" }
}
JSON

cat > tsconfig.json <<'JSON'
{
  "compilerOptions": {
    "strict": true,
    "noEmit": true,
    "target": "es2023",
    "module": "nodenext",
    "allowImportingTsExtensions": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
JSON

cat > .scratch/catalogue/issues/01-tag-books.md <<'MD'
# Tag books with metadata

Status: needs-alignment

## Goal
Librarians tag a book with free-form metadata from the cataloguing app.

## Context
The cataloguing app calls the `tagBook` mutation on `/graphql`. `metadata` is a `JSON` scalar. A request body on the wire:

```json
{"query":"mutation Tag($isbn: String!, $metadata: JSON!) { tagBook(isbn: $isbn, metadata: $metadata) { isbn tags { key value } } }","variables":{"isbn":"9780141439518","metadata":{"genre":"crime","shelf":"B4"}}}
```

## Interface
Approved. See `src/catalogue/index.ts`, served by `src/server.ts`.

## Behaviour
- Tagging a book with metadata {"genre": "crime", "shelf": "B4"} gives the book the tags genre=crime and shelf=B4.
- Tagging a book again replaces its earlier tags.

## Comments
MD

cat > src/catalogue/schema.graphql <<'GQL'
scalar JSON

type Tag {
  key: String!
  value: String!
}

type Book {
  isbn: String!
  tags: [Tag!]!
}

type Query {
  book(isbn: String!): Book
}

type Mutation {
  tagBook(isbn: String!, metadata: JSON!): Book!
}
GQL

cat > src/catalogue/index.ts <<'TS'
export type JsonValue = string | number | boolean | null | JsonValue[] | { [key: string]: JsonValue }

export type Tag = { key: string; value: string }

export type Book = { isbn: string; tags: Tag[] }

export type TagBookArgs = { isbn: string; metadata: JsonValue }

export type CatalogueResolvers = {
  Query: { book(parent: unknown, args: { isbn: string }): Promise<Book | null> }
  Mutation: { tagBook(parent: unknown, args: TagBookArgs): Promise<Book> }
}

export function createCatalogueResolvers(): CatalogueResolvers {
  throw new Error('createCatalogueResolvers is not implemented')
}
TS

cat > src/server.ts <<'TS'
import { readFileSync } from 'node:fs'
import { createServer } from 'node:http'
import { createSchema, createYoga } from 'graphql-yoga'
import { JSONResolver } from 'graphql-scalars'
import { createCatalogueResolvers } from './catalogue/index.ts'

const typeDefs = readFileSync(new URL('./catalogue/schema.graphql', import.meta.url), 'utf8')
const resolvers = { JSON: JSONResolver, ...createCatalogueResolvers() }

createServer(createYoga({ schema: createSchema({ typeDefs, resolvers }) })).listen(4000)
TS

git init --quiet --initial-branch=feat/tag-books
git add --all
git -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --quiet -m "feat: stub tag books interface"

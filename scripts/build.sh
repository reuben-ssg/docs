#!/usr/bin/env bash
#
# Cloudflare Workers Builds entry point.
#
# Produces `dist/`, which wrangler.jsonc points at via `assets.directory`.
# Workers Builds runs `npm clean-install` before this script, so it doesn't.

set -euo pipefail

echo "Building the site..."
npm run build

# Reuben writes `dist/_headers` itself (`[assets] headers = true`), and since 0.3.1 it keeps its
# `.dist.reuben-output` marker beside dist/ rather than in it, so nothing needs hiding from visitors.

echo "Build complete. Output: dist/"

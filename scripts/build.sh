#!/usr/bin/env bash
#
# Cloudflare Workers Builds entry point.
#
# Produces `dist/`, which wrangler.jsonc points at via `assets.directory`.
# Workers Builds runs `npm clean-install` before this script, so it doesn't.

set -euo pipefail

echo "Building the site..."
npm run build

# `.reuben-output` marks dist/ as Reuben's output folder; it isn't for visitors.
# Reuben writes `dist/_headers` itself (`[assets] headers = true`), so the script doesn't.
printf '.reuben-output\n' > dist/.assetsignore

echo "Build complete. Output: dist/"

#!/usr/bin/env bash
#
# Cloudflare Workers Builds entry point.
#
# Produces `dist/`, which wrangler.jsonc points at via `assets.directory`.
# Runs in the Cloudflare build environment (Node.js and npm pre-installed).

set -euo pipefail

echo "Installing dependencies..."
npm ci

echo "Building the site..."
npm run build

echo "Build complete. Output: dist/"

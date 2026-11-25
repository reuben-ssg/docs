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
printf '.reuben-output\n' > dist/.assetsignore

# Font files keep their names until replaced, so browsers may cache them for a year
# instead of rechecking on every page, which made text flash in the fallback font.
# Rename a font file when you change it.
cat > dist/_headers <<'EOF'
/fonts/*
  Cache-Control: public, max-age=31536000, immutable
EOF

echo "Build complete. Output: dist/"

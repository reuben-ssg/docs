#!/usr/bin/env bash
#
# Cloudflare Workers Builds deploy command for the production branch (main).
#
# Other branches don't use this script: they run Worker Previews through the
# dashboard's Preview command, which Cloudflare requires to invoke
# `npx wrangler preview` itself, so a wrapper script would be refused.
#
# Dashboard config:
#   Build command:    ./scripts/build.sh
#   Deploy command:   ./scripts/deploy.sh
#   Preview command:  npx wrangler preview

set -euo pipefail

echo "Deploying to production..."
npx wrangler deploy

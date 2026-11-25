#!/usr/bin/env bash
#
# Cloudflare Workers Builds deploy command.
#
# Runs after scripts/build.sh succeeds. Branches on WORKERS_CI_BRANCH
# (set by Cloudflare's build environment):
#
#   main branch  -> `wrangler deploy`  (production at reuben-ssg.dev)
#   any other    -> `wrangler versions upload --preview-alias <alias>`
#
# Preview aliases are DNS-safe: lowercase alphanumerics and hyphens,
# at most 63 characters. `feat/new-theme` becomes `feat-new-theme`.
# A branch name with no alphanumerics falls back to `preview-<short sha>`.
#
# Dashboard config:
#   Build command:   ./scripts/build.sh
#   Deploy command:  ./scripts/deploy.sh

set -euxo pipefail

if [ "${WORKERS_CI_BRANCH:-}" = "main" ]; then
  echo "Deploying to production..."
  npx wrangler deploy
else
  preview_alias=$(printf '%s' "${WORKERS_CI_BRANCH}" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/[^a-z0-9-]/-/g' -e 's/--*/-/g' -e 's/^-*//' -e 's/-*$//' \
    | cut -c1-63)
  if [ -z "${preview_alias}" ]; then
    commit="${WORKERS_CI_COMMIT_SHA:-$(git rev-parse HEAD)}"
    preview_alias="preview-$(printf '%s' "${commit}" | cut -c1-7)"
  fi
  echo "Deploying preview: ${preview_alias}"
  npx wrangler versions upload --preview-alias "${preview_alias}"
fi

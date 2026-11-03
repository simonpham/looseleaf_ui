#!/usr/bin/env bash
# Builds the gallery for the web into apps/gallery/build/web.
# Usage: tools/web/build.sh            build only
#        tools/web/build.sh --deploy   build, then deploy to Cloudflare (wrangler)
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root/apps/gallery"

flutter build web --release --no-wasm-dry-run

if [ "${1:-}" = "--deploy" ]; then
  npx --yes wrangler@4 deploy
fi

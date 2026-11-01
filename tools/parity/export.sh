#!/usr/bin/env bash
# Exports parity fixtures from a Looseleaf checkout into the Dart test folders.
# Usage: tools/parity/export.sh <looseleaf checkout> [exporter name ...]
set -euo pipefail

upstream="$(cd "${1:?usage: export.sh <looseleaf checkout> [exporter ...]}" && pwd)"
shift
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

[ -x "$here/node_modules/.bin/tsx" ] || (cd "$here" && npm install --silent)

exporters=("$@")
if [ ${#exporters[@]} -eq 0 ]; then
  for file in "$here"/exporters/*.ts; do exporters+=("$(basename "$file" .ts)"); done
fi

for name in "${exporters[@]}"; do
  echo "==> $name"
  (cd "$upstream" && LOOSELEAF_UI_ROOT="$root" "$here/node_modules/.bin/tsx" --tsconfig "$upstream/tsconfig.json" "$here/exporters/$name.ts")
done

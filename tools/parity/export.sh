#!/usr/bin/env bash
# Exports parity fixtures from a Looseleaf checkout into the Dart test folders.
# Usage: tools/parity/export.sh <looseleaf checkout> [exporter name ...]
set -euo pipefail

upstream="$(cd "${1:?usage: export.sh <looseleaf checkout> [exporter ...]}" && pwd)"
shift
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"

[ -x "$here/node_modules/.bin/tsx" ] || (cd "$here" && npm install --silent)

# Prefer an x64 Node (fetch-node.sh) so Math.* matches browsers bit for bit; see README.
node_bin="${PARITY_NODE:-}"
[ -z "$node_bin" ] && [ -x "$here/.node/bin/node" ] && node_bin="$here/.node/bin/node"
tsx=("$here/node_modules/.bin/tsx")
if [ -n "$node_bin" ]; then
  tsx=("$node_bin" "$here/node_modules/tsx/dist/cli.mjs")
  esbuild="$(ls "$here"/node_modules/@esbuild/*/bin/esbuild 2>/dev/null | head -n 1)"
  [ -n "$esbuild" ] && export ESBUILD_BINARY_PATH="$esbuild"
fi

exporters=("$@")
if [ ${#exporters[@]} -eq 0 ]; then
  for file in "$here"/exporters/*.ts; do exporters+=("$(basename "$file" .ts)"); done
fi

for name in "${exporters[@]}"; do
  echo "==> $name"
  (cd "$upstream" && LOOSELEAF_UI_ROOT="$root" "${tsx[@]}" --tsconfig "$upstream/tsconfig.json" "$here/exporters/$name.ts")
done

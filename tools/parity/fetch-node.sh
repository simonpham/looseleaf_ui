#!/usr/bin/env bash
# Downloads an x64 Node (same version as the local one) into tools/parity/.node for export.sh.
# On Apple Silicon, arm64 Node builds V8's fdlibm with fused multiply-adds, so Math.sin/cos/exp/log/atan2
# can differ from browsers (and from the Dart port) in the last bit. x64 Node under Rosetta does not.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
version="${1:-$(node -p process.version)}"
name="node-$version-darwin-x64"
base="https://nodejs.org/dist/$version"

tmp="$(mktemp -d)"
curl -sSfL "$base/$name.tar.gz" -o "$tmp/$name.tar.gz"
expected="$(curl -sSfL "$base/SHASUMS256.txt" | awk -v f="$name.tar.gz" '$2 == f { print $1 }')"
actual="$(shasum -a 256 "$tmp/$name.tar.gz" | awk '{ print $1 }')"
[ -n "$expected" ] && [ "$expected" = "$actual" ] || { echo "checksum mismatch for $name" >&2; exit 1; }

mkdir -p "$here/.node"
tar xzf "$tmp/$name.tar.gz" -C "$here/.node" --strip-components 1
"$here/.node/bin/node" -p '`x64 node ${process.version} ready (${process.arch})`'

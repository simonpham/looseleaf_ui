#!/usr/bin/env bash
# Analyzes apps, modules and packages with the oldest supported Flutter
# (pubspec `environment`), so newer-only APIs don't slip in.
# Works on a copy in .dart_tool, so the workspace lock and package config stay
# on the current SDK.
# Usage: tools/sdk/check_min_sdk.sh   (MIN_FLUTTER=<path to flutter> to override)
set -euo pipefail
version="3.32.8"
root="$(cd "$(dirname "$0")/../.." && pwd)"
flutter="${MIN_FLUTTER:-$HOME/fvm/versions/$version/bin/flutter}"
if [ ! -x "$flutter" ]; then
  echo "Flutter $version not found at $flutter. Install it with: fvm install $version" >&2
  exit 1
fi

copy="$root/.dart_tool/min_sdk_check"
mkdir -p "$copy"
rsync -a --delete \
  --exclude .git --exclude .dart_tool --exclude build --exclude node_modules \
  --exclude pubspec.lock \
  "$root/" "$copy/"

cd "$copy"
"$flutter" --suppress-analytics pub get >/dev/null
"$flutter" --suppress-analytics analyze apps modules packages

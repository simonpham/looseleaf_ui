#!/usr/bin/env bash
# Lists every public name of looseleaf_ui (and the looseleaf_ink it re-exports) that is
# ambiguous next to package:flutter/widgets.dart, package:flutter/services.dart and dart:core.
# Exits non-zero when one is found.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
pkg="$root/packages/looseleaf_ui"
probe="$pkg/.dart_tool/name_clash_probe_$$.dart"
trap 'rm -f "$probe"' EXIT

names() {
  grep -rhoE '^(abstract |final |sealed |base |interface |mixin )*(class|enum|typedef|mixin|extension type) [A-Z][A-Za-z0-9_]*' \
    "$pkg/lib" "$root/packages/looseleaf_ink/lib" | awk '{print $NF}'
  grep -rhoE '^(const|final) ([A-Za-z<>?, ]+ )?[a-zA-Z][A-Za-z0-9_]* =' \
    "$pkg/lib" "$root/packages/looseleaf_ink/lib" | sed -E 's/ =$//' | awk '{print $NF}'
  grep -rhoE '^[A-Za-z][A-Za-z0-9<>?, ]* [a-z][A-Za-z0-9_]*(<[^>]*>)?\(' \
    "$pkg/lib" "$root/packages/looseleaf_ink/lib" | sed -E 's/(<[^>]*>)?\($//' | awk '{print $NF}' |
    grep -vE '^(if|for|while|switch|return|main)$'
}

{
  echo "// ignore_for_file: unused_import, type=lint"
  echo "import 'package:flutter/services.dart';"
  echo "import 'package:flutter/widgets.dart';"
  echo "import 'package:looseleaf_ui/looseleaf_ui.dart';"
  echo
  echo "final List<Object?> probe = ["
  names | sort -u | sed -E 's/^(.*)$/  \1,/'
  echo "];"
} > "$probe"

clashes="$(cd "$pkg" && dart analyze "$probe" 2>&1 | grep 'ambiguous_import' |
  sed -E "s/.*The name '([^']+)'.*/\1/" | sort -u || true)"
if [ -n "$clashes" ]; then
  echo "Ambiguous names:"
  echo "$clashes"
  exit 1
fi
echo "No name clashes."

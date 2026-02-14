#!/bin/bash
# Build a .plasmoid file for KDE Store upload
set -euo pipefail

WIDGET_ID="com.github.p3kj.claudemeter"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$SCRIPT_DIR/${WIDGET_ID}.plasmoid"

rm -f "$OUT"

cd "$SCRIPT_DIR"
7z a -tzip "$OUT" \
    metadata.json \
    icon.png \
    LICENSE \
    contents/

echo "Created $OUT"
echo "Upload this file to https://store.kde.org"

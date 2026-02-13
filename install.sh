#!/bin/bash
# Install/update the Claude Meter applet for KDE 6 Plasma
set -euo pipefail

WIDGET_ID="com.github.p3kj.claudemeter"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Make fetch script executable
chmod +x "$SCRIPT_DIR/contents/scripts/fetch_usage.sh"

# Install or update
if kpackagetool6 -t Plasma/Applet -l 2>/dev/null | grep -q "$WIDGET_ID"; then
    echo "Updating existing installation..."
    kpackagetool6 -t Plasma/Applet -u "$SCRIPT_DIR"
else
    echo "Installing widget..."
    kpackagetool6 -t Plasma/Applet -i "$SCRIPT_DIR"
fi

echo "Done. Test with: plasmawindowed $WIDGET_ID"

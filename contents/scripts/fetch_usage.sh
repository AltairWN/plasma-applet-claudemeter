#!/bin/bash
# Fetch Claude Code usage data from the Anthropic API
# Outputs JSON to stdout. Always exits 0; errors reported as JSON.

set -euo pipefail

CRED_FILE="$HOME/.claude/.credentials.json"

error_json() {
    python3 -c "import json,sys; print(json.dumps({'error':sys.argv[1],'message':sys.argv[2]}))" "$1" "$2"
    exit 0
}

# Check credentials file exists
if [ ! -f "$CRED_FILE" ]; then
    error_json "no_credentials" "Credentials file not found"
fi

# Extract token and check expiry via python3, reading creds from file (not args)
read -r TOKEN EXPIRED < <(python3 -c "
import json, sys, time
try:
    with open(sys.argv[1]) as f:
        creds = json.load(f)
    oauth = creds['claudeAiOauth']
    token = oauth['accessToken']
    expires_at = oauth.get('expiresAt', 0)
    now_ms = int(time.time() * 1000)
    expired = '1' if (expires_at and now_ms > expires_at) else '0'
    print(token, expired)
except Exception as e:
    sys.exit(1)
" "$CRED_FILE" 2>/dev/null) || error_json "parse_error" "Failed to parse credentials file"

if [ "$EXPIRED" = "1" ]; then
    error_json "token_expired" "OAuth token has expired. Run claude to refresh."
fi

# Call usage API - auth header passed via stdin (-K -) to avoid token in /proc/cmdline
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

HTTP_CODE=$(printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" | \
    curl -s --max-time 10 -o "$TMPFILE" -w '%{http_code}' \
    -K - \
    -H "anthropic-beta: oauth-2025-04-20" \
    https://api.anthropic.com/api/oauth/usage 2>/dev/null) || error_json "network_error" "Failed to reach Anthropic API"

TOKEN=""

if [ "$HTTP_CODE" != "200" ]; then
    error_json "api_error" "API returned HTTP $HTTP_CODE"
fi

# Validate and output response - pipe through stdin, never in args
python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    if 'error' in data:
        msg = data.get('error', {})
        if isinstance(msg, dict):
            msg = msg.get('message', str(data))
        json.dump({'error': 'api_error', 'message': str(msg)}, sys.stdout)
    else:
        json.dump(data, sys.stdout)
except Exception:
    json.dump({'error': 'parse_error', 'message': 'Invalid JSON from API'}, sys.stdout)
" < "$TMPFILE"

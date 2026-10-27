#!/bin/sh
# ==============================================================================
# ArcherGuard C6 — Common Helpers & Security Module (router/lib/common.sh)
# Max lines: < 250 (DRY Principle Enforced)
# ==============================================================================

# Load optional external configuration
CONFIG_FILE="/etc/opennds/sync.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

API_SECRET="${ROUTER_SECRET_KEY:-$API_SECRET}"

# Send standardized HTTP Headers with restricted CORS and Cache-Control
send_header() {
    printf "Content-Type: application/json; charset=utf-8\r\n"
    _origin="$HTTP_ORIGIN"
    case "$_origin" in
        "http://192.168.1.1"*|"https://192.168.1.1"*|"https://wifihandler.vercel.app"*)
            printf "Access-Control-Allow-Origin: %s\r\n" "$_origin"
            printf "Access-Control-Allow-Credentials: true\r\n"
            ;;
        *)
            # Safe default: omit Access-Control-Allow-Origin for untrusted third-party origins
            ;;
    esac
    printf "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n"
    printf "Access-Control-Allow-Headers: Content-Type, X-Router-Secret, Authorization\r\n"
    printf "Cache-Control: no-cache, no-store, must-revalidate\r\n\r\n"
}

# Unified success response helper (DRY)
json_ok() {
    send_header
    printf '{"status":"ok","message":"%s"}\n' "$1"
    exit 0
}

# Unified error response helper (DRY)
json_error() {
    send_header
    printf '{"status":"error","message":"%s"}\n' "$1"
    exit 0
}

# Authentication check for mutating and sensitive actions
check_auth() {
    _payload="$1"
    _auth="$HTTP_X_ROUTER_SECRET"
    [ -z "$_auth" ] && _auth="$X_ROUTER_SECRET"
    [ -z "$_auth" ] && _auth=$(printf "%s" "$HTTP_AUTHORIZATION" | sed -e 's/^[Bb][Ee][Aa][Rr][Ee][Rr][[:space:]]*//')
    [ -z "$_auth" ] && _auth=$(printf "%s" "$QUERY_STRING" | sed -n 's/.*token=\([^&]*\).*/\1/p')
    [ -z "$_auth" ] && _auth=$(printf "%s" "$QUERY_STRING" | sed -n 's/.*secret=\([^&]*\).*/\1/p')
    [ -z "$_auth" ] && [ -n "$_payload" ] && _auth=$(extract_param "secret" "$_payload")
    [ -z "$_auth" ] && [ -n "$_payload" ] && _auth=$(extract_param "token" "$_payload")

    _matched=0
    if [ -n "$_auth" ]; then
        [ -n "$API_SECRET" ] && [ "$_auth" = "$API_SECRET" ] && _matched=1
        [ -n "$ROUTER_SECRET_KEY" ] && [ "$_auth" = "$ROUTER_SECRET_KEY" ] && _matched=1
        [ -n "$ARCHER_C6_SECRET" ] && [ "$_auth" = "$ARCHER_C6_SECRET" ] && _matched=1
    fi

    if [ "$_matched" -ne 1 ]; then
        send_header
        printf '{"error":"unauthorized","message":"Invalid or missing X-Router-Secret"}\n'
        exit 0
    fi
}

# Extract key from JSON payload or query string (DRY parameter extractor)
extract_param() {
    _key="$1"
    _payload="$2"
    _val=""
    if [ -n "$_payload" ]; then
        _val=$(printf "%s" "$_payload" | sed -n "s/.*\"$_key\"[ ]*:[ ]*\"\([^\"]*\)\".*/\1/p")
        if [ -z "$_val" ]; then
            _val=$(printf "%s" "$_payload" | sed -n "s/.*\"$_key\"[ ]*:[ ]*\([0-9a-zA-Z._-]*\).*/\1/p")
        fi
    fi
    if [ -z "$_val" ]; then
        _val=$(printf "%s" "$QUERY_STRING" | sed -n "s/.*$_key=\([^&]*\).*/\1/p")
    fi
    printf "%s" "$_val"
}

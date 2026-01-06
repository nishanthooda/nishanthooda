#!/usr/bin/env bash

set -e

# -----------------------------
# Usage:
# upload.sh <local_image_path> <remote_path>
#
# Example:
# upload.sh IMG_0800.HEIC 2026-01/parents-gym.jpg
# -----------------------------

LOCAL_PATH="$1"
REMOTE_PATH="$2"

if [[ -z "$LOCAL_PATH" || -z "$REMOTE_PATH" ]]; then
  echo "Usage: upload.sh <local_image_path> <remote_path>"
  exit 1
fi

if [[ ! -f "$LOCAL_PATH" ]]; then
  echo "File not found: $LOCAL_PATH"
  exit 1
fi

# -----------------------------
# Resolve repo root (works from anywhere)
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env.local"

if [[ ! -f "$ENV_FILE" ]]; then
  echo ".env.local not found at $ENV_FILE"
  exit 1
fi

# Load env vars
export $(grep -v '^#' "$ENV_FILE" | xargs)

if [[ -z "$UPLOAD_TOKEN" ]]; then
  echo "UPLOAD_TOKEN not set in .env.local"
  exit 1
fi

# -----------------------------
# Handle HEIC conversion
# -----------------------------
UPLOAD_PATH="$LOCAL_PATH"
TMP_FILE=""

EXT="${LOCAL_PATH##*.}"
EXT_LOWER="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"

if [[ "$EXT_LOWER" == "heic" ]]; then
  TMP_FILE="$(mktemp /tmp/uploadshot-XXXXXX.jpg)"
  sips -s format jpeg "$LOCAL_PATH" --out "$TMP_FILE" > /dev/null
  UPLOAD_PATH="$TMP_FILE"

  # Ensure remote path ends in .jpg
  REMOTE_PATH="${REMOTE_PATH%.*}.jpg"
fi

# -----------------------------
# Detect content type
# -----------------------------
CONTENT_TYPE="$(file --mime-type -b "$UPLOAD_PATH")"

# -----------------------------
# Upload
# -----------------------------
DOMAIN="https://nishanthooda.com"

RESPONSE=$(curl -s -X POST \
  -H "Content-Type: $CONTENT_TYPE" \
  -H "x-upload-secret: $UPLOAD_TOKEN" \
  --data-binary @"$UPLOAD_PATH" \
  "$DOMAIN/api/upload?filename=$REMOTE_PATH")

# -----------------------------
# Cleanup temp file
# -----------------------------
if [[ -n "$TMP_FILE" && -f "$TMP_FILE" ]]; then
  rm "$TMP_FILE"
fi

# -----------------------------
# Output result
# -----------------------------
echo "$RESPONSE"


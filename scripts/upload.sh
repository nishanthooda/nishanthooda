#!/usr/bin/env bash

set -e

# Usage:
# ./scripts/upload-screenshot.sh path/to/image.png 2026-01/image.png

IMAGE_PATH="$1"
REMOTE_PATH="$2"

if [[ -z "$IMAGE_PATH" || -z "$REMOTE_PATH" ]]; then
  echo "Usage: upload-screenshot.sh <local_image_path> <remote_path>"
  echo "Example: upload-screenshot.sh ./test.png 2026-01/test.png"
  exit 1
fi

if [[ ! -f "$IMAGE_PATH" ]]; then
  echo "File not found: $IMAGE_PATH"
  exit 1
fi

# Load env vars from .env.local
if [[ -f ".env.local" ]]; then
  export $(grep -v '^#' .env.local | xargs)
else
  echo ".env.local not found"
  exit 1
fi

if [[ -z "$UPLOAD_TOKEN" ]]; then
  echo "UPLOAD_TOKEN not set in .env.local"
  exit 1
fi

DOMAIN="https://nishanthooda.com"

curl -X POST \
  -H "Content-Type: image/png" \
  -H "x-upload-secret: $UPLOAD_TOKEN" \
  --data-binary @"$IMAGE_PATH" \
  "$DOMAIN/api/upload?filename=$REMOTE_PATH"


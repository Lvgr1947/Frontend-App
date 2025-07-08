#!/bin/bash
# Usage: ./test_endpoints.sh <BASE_URL>
# Example: ./test_endpoints.sh venudev.duckdns.org:32680

set -e

BASE_URL=$1

if [ -z "$BASE_URL" ]; then
  echo " Base URL not provided"
  exit 1
fi

echo "🔍 Testing app endpoints on http://$BASE_URL"

# List of endpoints to check
ENDPOINTS=(
  "/staging"
)

for endpoint in "${ENDPOINTS[@]}"; do
  echo "➡️  Checking $endpoint..."
  curl -sSf "http://$BASE_URL$endpoint" > /dev/null
  echo "✅ $endpoint OK"
done

echo "✅ All integration tests passed!"

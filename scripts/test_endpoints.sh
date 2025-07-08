#!/bin/bash
# Usage: ./test_endpoints.sh <BASE_URL>
# Example: ./test_endpoints.sh venudev.duckdns.org:32680

set -e

BASE_URL=$1

if [ -z "$BASE_URL" ]; then
  echo " Base URL not provided"
  exit 1
fi

echo "🔍 Testing app endpoints on https://$BASE_URL"

Nodeport="30756"

for endpoint in "${ENDPOINTS[@]}"; do
  echo "➡️  Checking $endpoint..."
  curl -sSf "https://$BASE_URL$Nodeport" > /dev/null
  echo "✅ $endpoint OK"
done

echo "✅ All integration tests passed!"

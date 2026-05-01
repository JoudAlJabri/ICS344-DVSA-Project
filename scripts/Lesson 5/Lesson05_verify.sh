#!/usr/bin/env bash
# Lesson 05 — Post-fix verification
#
# Three tests confirm the router-level admin gate is enforced:
#   Test 1: Replay the original injection payload — should fail with
#           "unknown action" (Lesson 1's JSON.parse fix prevents
#           reconstruction of the function).
#   Test 2: Direct call to an admin-only action with a non-admin token
#           — should return 403 Forbidden.
#   Test 3: Legitimate user action — should still succeed.
#
# Usage:
#   bash lesson05_verify.sh <API_GATEWAY_URL> <USER_JWT> <PATH_TO_EXPLOIT_JSON> <ORDER_ID>

set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <API_GATEWAY_URL> <USER_JWT> <PATH_TO_EXPLOIT_JSON> <ORDER_ID>"
  exit 1
fi

API_URL="$1"
JWT="$2"
PAYLOAD_FILE="$3"
ORDER_ID="$4"

echo "--- Test 1: Replay injection payload ---"
echo "Expected: {\"status\":\"err\",\"msg\":\"unknown action\"}"
curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "authorization: $JWT" \
  --data-binary "@$PAYLOAD_FILE"
echo -e "\n"

echo "--- Test 2: Direct admin-only action as non-admin ---"
echo "Expected: {\"status\":\"err\",\"msg\":\"Forbidden: admin only\"}"
curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "authorization: $JWT" \
  -d "{\"action\":\"complete\",\"order-id\":\"$ORDER_ID\"}"
echo -e "\n"

echo "--- Test 3: Legitimate user action (orders list) ---"
echo "Expected: {\"status\":\"ok\",\"orders\":[...]}"
curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "authorization: $JWT" \
  -d '{"action":"orders"}'
echo -e "\n"

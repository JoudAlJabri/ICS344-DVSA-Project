#!/usr/bin/env bash
# Lesson 07 — Post-fix verification
#
# Verifies the IAM layer independently blocks privilege escalation,
# even when the application-layer injection (Lesson 1) is reachable.
#
# Procedure:
#   1. Temporarily revert the Lesson 1 fix so the injection vector
#      is reachable again (DO THIS IN A LAB ONLY).
#   2. Place a fresh order via the DVSA web UI; capture its order-id.
#   3. Run this script with that order-id to fire the Lesson 5 payload.
#   4. Inspect CloudWatch — expect AccessDeniedException on
#      DVSA-ADMIN-UPDATE-ORDERS.
#   5. Refresh the DVSA Orders page — order status should remain
#      `processed` (NOT flipped to `paid`).
#   6. RESTORE the Lesson 1 fix immediately after the test.
#
# Usage:
#   bash lesson07_verify.sh <API_URL> <USER_JWT> <PATH_TO_LESSON5_EXPLOIT_JSON>

set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <API_URL> <USER_JWT> <PATH_TO_LESSON5_EXPLOIT_JSON>"
  exit 1
fi

API_URL="$1"
JWT="$2"
PAYLOAD_FILE="$3"

echo "--- Firing Lesson 5 injection payload ---"
echo "Expected: client sees 'Internal server error', but CloudWatch logs"
echo "          AccessDeniedException for DVSA-ADMIN-UPDATE-ORDERS."
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "authorization: $JWT" \
  --data-binary "@$PAYLOAD_FILE"
echo -e "\n"

echo "--- Now check CloudWatch ---"
echo "  Log group: /aws/lambda/DVSA-ORDER-MANAGER"
echo "  Look for: 'INVOKE ERR' / 'not authorized to perform: lambda:InvokeFunction'"
echo "            on DVSA-ADMIN-UPDATE-ORDERS"
echo ""
echo "--- Now check DVSA Orders page ---"
echo "  The targeted order's status should still be 'processed'."
echo ""
echo "--- IMPORTANT: re-apply the Lesson 1 fix before leaving the lab. ---"

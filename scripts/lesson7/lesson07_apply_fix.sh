#!/usr/bin/env bash
# Lesson 07 — Apply the IAM least-privilege fix
#
# Two actions:
#   1. Detach AWSLambdaRole (the over-broad managed policy)
#   2. Attach DVSA-OrderManager-LeastPrivilege as an inline policy
#
# Pre-conditions:
#   - AWS CLI configured with credentials that can manage IAM
#   - lesson07_DVSA-OrderManager-LeastPrivilege.json edited so that
#     <ACCOUNT_ID> is replaced with your real AWS account ID
#
# Usage:
#   bash lesson07_apply_fix.sh <ROLE_NAME> <PATH_TO_LEAST_PRIVILEGE_JSON>
#
# Example:
#   bash lesson07_apply_fix.sh \
#     "serverlessrepo-OWASP-DVSA-OrderManagerFunctionRole-XXXXXXXXX" \
#     ./lesson07_DVSA-OrderManager-LeastPrivilege.json

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <ROLE_NAME> <PATH_TO_LEAST_PRIVILEGE_JSON>"
  exit 1
fi

ROLE_NAME="$1"
POLICY_FILE="$2"

echo "--- Step 1: Detaching AWSLambdaRole managed policy ---"
aws iam detach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
echo "Detached."

echo "--- Step 2: Attaching DVSA-OrderManager-LeastPrivilege inline policy ---"
aws iam put-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "DVSA-OrderManager-LeastPrivilege" \
  --policy-document "file://$POLICY_FILE"
echo "Attached."

echo "--- Done. Verify with: ---"
echo "aws iam list-attached-role-policies --role-name $ROLE_NAME"
echo "aws iam get-role-policy --role-name $ROLE_NAME --policy-name DVSA-OrderManager-LeastPrivilege"

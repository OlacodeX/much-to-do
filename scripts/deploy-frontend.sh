#!/usr/bin/env bash
set -euo pipefail

: "${S3_BUCKET:?Set S3_BUCKET}"
: "${CLOUDFRONT_DISTRIBUTION_ID:?Set CLOUDFRONT_DISTRIBUTION_ID}"
: "${ALB_DNS_NAME:?Set ALB_DNS_NAME}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/Client"

npm ci
VITE_API_BASE_URL="http://${ALB_DNS_NAME}" npm run build
aws s3 sync dist/ "s3://${S3_BUCKET}" --delete
aws cloudfront create-invalidation \
  --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
  --paths "/*"

echo "Frontend deployed."

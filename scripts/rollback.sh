#!/usr/bin/env bash
set -euo pipefail

: "${ASG_NAME:?Set ASG_NAME}"
: "${AWS_REGION:=us-east-1}"

echo "Rolling back by reducing ASG desired capacity (manual recovery)."
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name "$ASG_NAME" \
  --desired-capacity 1 \
  --region "$AWS_REGION"

echo "Redeploy a previous ECR image tag and run deploy-backend.sh for full rollback."

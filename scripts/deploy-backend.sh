#!/usr/bin/env bash
set -euo pipefail

: "${ECR_REPOSITORY:?Set ECR_REPOSITORY}"
: "${ASG_NAME:?Set ASG_NAME}"
: "${AWS_REGION:=us-east-1}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/Server/MuchToDo"

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "${ECR_REPOSITORY%%/*}"

docker build -t assessment-backend .
docker tag assessment-backend:latest "${ECR_REPOSITORY}:latest"
docker push "${ECR_REPOSITORY}:latest"

aws autoscaling start-instance-refresh \
  --auto-scaling-group-name "$ASG_NAME" \
  --region "$AWS_REGION"

echo "Backend image pushed and instance refresh started."

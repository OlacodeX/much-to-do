# StartTech Application (starttech-application)

Full-stack assessment app: React (`Client/`) and Golang API (`Server/MuchToDo/`).

| Assessment path | This repo |
|-----------------|-----------|
| `frontend/` | `Client/` |
| `backend/` | `Server/MuchToDo/` |

## Prerequisites

1. Deploy [starttech-infra](https://github.com/OlacodeX/assessment-infra) and run `terraform apply`.
2. Allowlist `terraform output -raw nat_gateway_public_ip` in **MongoDB Atlas**.
3. Set GitHub secrets from Terraform outputs.

## GitHub secrets

| Secret | Source |
|--------|--------|
| `AWS_ACCESS_KEY_ID` | IAM assessor user |
| `AWS_SECRET_ACCESS_KEY` | IAM assessor user |
| `S3_BUCKET` | `s3_bucket_name` |
| `CLOUDFRONT_DISTRIBUTION_ID` | `cloudfront_distribution_id` |
| `ECR_REPOSITORY` | `ecr_repository_url` |
| `ASG_NAME` | `autoscaling_group_name` |
| `ALB_DNS_NAME` | `alb_dns_name` (hostname only) |

## CI/CD

- `.github/workflows/frontend-ci-cd.yml` — build, audit, S3, CloudFront
- `.github/workflows/backend-ci-cd.yml` — test, ECR, instance refresh, smoke `/health`

Branch: `feature/full-stack`

## Local scripts

```bash
export S3_BUCKET=... CLOUDFRONT_DISTRIBUTION_ID=... ALB_DNS_NAME=...
./scripts/deploy-frontend.sh

export ECR_REPOSITORY=... ASG_NAME=...
./scripts/deploy-backend.sh

./scripts/health-check.sh "$ALB_DNS_NAME" /health
```

## Documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md)
- [RUNBOOK.md](./RUNBOOK.md)

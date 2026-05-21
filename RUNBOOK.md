# Application Runbook

## Deploy failed smoke test

1. Confirm Atlas allows infra NAT IP.
2. Confirm secrets match latest `terraform output` (ALB DNS changes after recreate).
3. Check target group health in AWS Console.
4. On an instance (SSM): `sudo docker logs backend`, `curl localhost:8080/health`.

## Rollback

```bash
export ASG_NAME=...
./scripts/rollback.sh
# Then redeploy a known-good ECR tag via deploy-backend.sh
```

## Health check

```bash
./scripts/health-check.sh <alb-dns> /health
./scripts/health-check.sh <alb-dns> /ping
```

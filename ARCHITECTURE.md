# Application Architecture

## Components

- **Client/** — React SPA (Vite), deployed to S3 + CloudFront
- **Server/MuchToDo/** — Golang API in Docker on EC2 behind ALB
- **MongoDB Atlas** — primary database
- **Redis** — ElastiCache (via starttech-infra)

## Request flow

```text
User → CloudFront → S3 (static)
User → ALB → ASG (EC2) → Docker API → MongoDB / Redis
```

## CI/CD

1. Infra repo applies Terraform.
2. Backend workflow pushes image to ECR and refreshes ASG.
3. Frontend workflow syncs `Client/dist` to S3 and invalidates CloudFront.

## Configuration

Production API URL is injected at build time: `VITE_API_BASE_URL=http://<ALB_DNS_NAME>`.

Backend env on EC2 (from infra user-data): `MONGO_URI`, `JWT_SECRET_KEY`, `REDIS_ADDR`, `DB_NAME`, `ENABLE_CACHE`.

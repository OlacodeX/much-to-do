# MuchToDo API

A robust RESTful API for a ToDo application built with Go (Golang). This project features user authentication, JWT-based session management, CRUD operations for ToDo items, and an optional Redis caching layer.

The API is built with a clean, layered architecture to separate concerns, making it scalable and easy to maintain. It includes a full suite of unit and integration tests and provides interactive API documentation via Swagger.

## Features

* **User Management**: Secure user registration, login, update, and deletion.
* **Authentication**: JWT-based authentication that supports both `httpOnly` cookies (for web clients) and `Authorization` headers.
* **CRUD for ToDos**: Full create, read, update, and delete functionality for user-specific ToDo items.
* **Structured Logging**: Configurable, structured JSON logging with request context for production-ready monitoring.
* **Optional Caching**: Redis-backed caching layer that can be toggled on or off via environment variables.
* **API Documentation**: Auto-generated interactive Swagger documentation.
* **Testing**: Comprehensive unit and integration test suites.
* **Graceful Shutdown**: The server shuts down gracefully, allowing active requests to complete.

## Prerequisites

To run this project locally, you will need the following installed:

* **Go**: Version 1.21 or later.
* **Swag CLI**: To generate the Swagger API documentation.
* **Make** (optional, for easier command execution):

  On macOS, you can install `make` via Homebrew if it's not already available:

  ```bash
  brew install make
  ```

  On Linux, `make` is usually pre-installed or available via your package manager.

```bash
go install github.com/swaggo/swag/cmd/swag@latest
```

## Using Make

This project includes a `Makefile` to simplify common development tasks. You can use `make <target>` to run commands such as starting the server, building, running tests, and managing Docker containers.

## Getting Started

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd much-to-do/Server/MuchToDo
```

### 2. Configure Environment Variables

Create a `.env` file in the root of the project by copying the example.

```bash
cp .env.example .env
```

Now, open the `.env` file and **change the** `JWT_SECRET_KEY` to a new, long, random string.

Also, ensure that the `MONGO_URI` and `DB_NAME` points to your local MongoDB instance and db.

You can leave the other variables as they are for local development.

### 3. Start Local Dependencies

With Docker running, start the MongoDB and Redis containers using Docker Compose.

```bash
docker-compose up -d
```
**Or using Make:**
```bash
make dc-up
```

### 4. Install Go Dependencies

Download the necessary Go modules.

```bash
go mod tidy
```
**Or using Make:**
```bash
make tidy
```

### 5. Generate API Documentation

Generate the Swagger/OpenAPI documentation from the code comments.

```bash
swag init -g cmd/api/main.go
```
**Or using Make:**
```bash
make generate-docs
```

### 6. Run the Application

You can now run the API server.

```bash
go run ./cmd/api/main.go
```
**Or using Make (also generates docs first):**
```bash
make run
```

The server will start, and you should see log output in your terminal.

* The API will be available at `http://localhost:8080`.
* The interactive Swagger documentation will be at `http://localhost:8080/swagger/index.html`.

## Running Tests

The project includes both unit and integration tests.

### Run Unit Tests

These tests are fast and do not require any external dependencies.

```bash
go test ./...
```
**Or using Make:**
```bash
make unit-test
```

### Run Integration Tests

These tests require Docker to be running as they spin up their own temporary database and cache containers.

```bash
INTEGRATION=true go test -v --tags=integration ./...
```
**Or using Make:**
```bash
make integration-test
```

The `INTEGRATION=true` environment variable is required to explicitly enable these tests. The `-v` flag provides verbose output.

## Other Useful Make Commands

- **Build the binary:**  
  ```bash
  make build
  ```
- **Clean build artifacts:**  
  ```bash
  make clean
  ```
- **Stop Docker containers:**  
  ```bash
  make dc-down
  ```
- **Restart Docker containers:**  
  ```bash
  make dc-restart
  ```

Refer to the `Makefile` for more available commands.

## Deployments

Run everything from `Server/MuchToDo`:

```bash
cd much-to-do/Server/MuchToDo
```

You need **Docker Desktop**, **kind**, and **kubectl**. On Windows, run the scripts from **Git Bash** (or call them from PowerShell with Git Bash if `kind` is only on PATH there).

### One-time setup

```bash
cp .env.example .env
```

Edit `.env`: set `JWT_SECRET_KEY` and `MONGO_URI` (for Compose, use the Docker service hostname `mongodb`):

```env
MONGO_URI=mongodb://root:example@mongodb:27017/much_todo_db?authSource=admin&replicaSet=rs0
```

Create the MongoDB keyfile for Compose:

```bash
openssl rand -base64 756 > mongodb.key
chmod 400 mongodb.key
```

### Docker Compose

```bash
bash scripts/docker-run.sh
```

API: http://localhost:8080 — health check: http://localhost:8080/health — Swagger: http://localhost:8080/swagger/index.html

Stop:

```bash
docker compose down
```

### Kubernetes (Kind)

Stop Compose first so port 8080 is free, then run cleanup and deploy:

```bash
docker compose down
bash scripts/k8s-cleanup.sh
bash scripts/k8s-deploy.sh
```

The script creates cluster `muchtodo-cluster`, installs ingress-nginx, applies manifests under `kubernetes/`, builds the backend image, loads it into Kind, and checks health.

API: http://localhost:8080/health

Verify:

```bash
kubectl get pods -n muchtodo
curl http://localhost:8080/health
```

Remove everything:

```bash
bash scripts/k8s-cleanup.sh
```

**Windows (PowerShell)** if `kind` is not in Git Bash PATH:

```powershell
cd Server\MuchToDo
& "C:\Program Files\Git\bin\bash.exe" scripts/k8s-cleanup.sh
& "C:\Program Files\Git\bin\bash.exe" scripts/k8s-deploy.sh
```

If deploy fails because an old cluster exists without the right port mapping, run `k8s-cleanup.sh` and `k8s-deploy.sh` again. If Docker cannot pull images (`registry-1.docker.io: no such host`), fix your network/DNS and restart Docker Desktop.
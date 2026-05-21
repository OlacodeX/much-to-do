FROM golang:1.25.1-alpine3.22 AS builder

# Set working directory
WORKDIR /app

# Install git
RUN apk add --no-cache git

# Copy dependency files first
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy application source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/api

# =========================
# Runtime
# =========================

FROM alpine:3.20

# Set working directory
WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache ca-certificates wget

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built binary from builder stage
COPY --from=builder /app/server .

# Change ownership
RUN chown appuser:appgroup /app/server

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
CMD wget --spider http://localhost:8080/ping || exit 1

# Start application
CMD ["./server"]
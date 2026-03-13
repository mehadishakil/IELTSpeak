# Default build: chunked REST API for >30s audio
# For Azure Speech SDK continuous mode, use Dockerfile.sdk instead
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /server ./cmd/server

FROM alpine:3.19
RUN apk add --no-cache ffmpeg ca-certificates
COPY --from=builder /server /server
EXPOSE 8080
CMD ["/server"]

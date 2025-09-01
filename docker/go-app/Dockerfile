ARG GO_VERSION=1.19

# == Build Image === #
FROM golang:${GO_VERSION} AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN ls *.go > /dev/null 2>&1 && src_dir=. || src_dir=./cmd; \
    CGO_ENABLED=0 GOOS=linux go build -o app $src_dir

# === Run Image === #
FROM alpine:latest
WORKDIR /app
COPY --from=build /app/app .
EXPOSE 8080
ENTRYPOINT ["/app/app"]

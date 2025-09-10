ARG GO_VERSION=1.19
ARG GO_RUN_IMAGE=alpine:latest

# == Build Image === #
FROM golang:${GO_VERSION} AS build
ARG CGO_ENABLED=0
RUN apt update && apt install -y libv8-dev
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN src_dir=$(find . -type f -name '*.go' -exec dirname {} \; | sort | uniq | head -n1) && \
    echo "Building from $src_dir" && \
    CGO_ENABLED=${CGO_ENABLED} GOOS=linux go build -o app "$src_dir"

# === Run Image === #
FROM ${GO_RUN_IMAGE}
WORKDIR /app
COPY --from=build /app/app .
EXPOSE 8080
ENTRYPOINT ["/app/app"]


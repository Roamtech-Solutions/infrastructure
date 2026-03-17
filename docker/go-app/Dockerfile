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
RUN mkdir -p resources migrations
ENV GOWORK=off
#RUN src_dir=$(find . -type f -name '*.go' -exec dirname {} \; | sort | uniq | head -n1) && \
RUN src=$(grep -rn "func main" | grep -v migrate | head -1 | cut -d ':' -f 1) && \
    echo "Building from $src" && \
    CGO_ENABLED=${CGO_ENABLED} GOOS=linux go build -o app "$src"


# === Run Image === #
FROM ${GO_RUN_IMAGE}
WORKDIR /app
COPY --from=build /app/resources ./resources
COPY --from=build /app/migrations ./migrations
COPY --from=build /app/app .
EXPOSE 8080
ENTRYPOINT ["/app/app"]


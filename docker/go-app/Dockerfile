ARG GO_VERSION=1.19

# == Build Image === #
FROM golang:${GO_VERSION} AS build
# Set destination for COPY
WORKDIR /app
# Download Go modules
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o app

# === Run Image === #
FROM alpine:latest
WORKDIR /app
COPY --from=build /app/app .
EXPOSE 8080
ENTRYPOINT ["/app/app"]


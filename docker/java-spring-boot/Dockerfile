# Build Container
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -Dmaven.test.skip

# Run image
FROM openjdk:17-slim

# TODO: This should be updated for whichever service is using it
ARG NAME="ipsl-rest-wrapper"
ARG VERSION="0.0.1-SNAPSHOT"

WORKDIR /app
COPY --from=build /app/target/${NAME}-${VERSION}.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]


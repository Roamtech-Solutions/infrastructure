ARG NAME 
ARG VERSION
ARG JAVA_VERSION=17

# Build Container
FROM eclipse-temurin:${JAVA_VERSION}-jdk-alpine AS build
ARG NAME 
ARG VERSION

RUN apk update && apk add --no-cache maven

WORKDIR /app
COPY . .
RUN mvn clean package \
	-DartifactId=${NAME} \
	-Dversion=${VERSION} \
	-Dmaven.test.skip

# Run image
FROM eclipse-temurin:${JAVA_VERSION}-jre-alpine
ARG NAME 
ARG VERSION

WORKDIR /app
COPY --from=build /app/target/${NAME}-${VERSION}.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]


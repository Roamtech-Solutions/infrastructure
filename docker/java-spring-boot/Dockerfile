ARG NAME 
ARG VERSION
ARG JAVA_VERSION=eclipse-temurin:17-jre-alpine

# Build Container
FROM openjdk:${JAVA_VERSION} AS build
ARG NAME 
ARG VERSION

RUN apt update && apt install -y maven

WORKDIR /app
COPY . .
RUN mvn clean package \
	-DartifactId=${NAME} \
	-Dversion=${VERSION} \
	-Dmaven.test.skip

# Run image
FROM openjdk:${JAVA_VERSION}
ARG NAME 
ARG VERSION

WORKDIR /app
COPY --from=build /app/target/${NAME}-${VERSION}.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]


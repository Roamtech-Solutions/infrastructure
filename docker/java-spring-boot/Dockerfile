ARG NAME 
ARG VERSION
ARG JAVA_VERSION=17

# Build Container
FROM maven:3.8.5-openjdk-${JAVA_VERSION} AS build
ARG NAME 
ARG VERSION

WORKDIR /app
COPY . .
RUN mvn clean package \
	-DartifactId=${NAME} \
	-Dversion=${VERSION} \
	-Dmaven.test.skip

# Run image
FROM openjdk:${JAVA_VERSION}-slim
ARG NAME 
ARG VERSION

WORKDIR /app
COPY --from=build /app/target/${NAME}-${VERSION}.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]


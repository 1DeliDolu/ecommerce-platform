FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q dependency:go-offline
COPY src ./src
RUN mvn -DskipTests package

FROM eclipse-temurin:25-jre-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /app/target/*.jar app.jar
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
USER app
EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]

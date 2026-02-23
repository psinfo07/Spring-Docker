# ===== Build Stage =====
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY pom.xml .
RUN mvn -B -q -e -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -B -q -e clean package -DskipTests

# ===== Run Stage (distroless-like base with JRE17) =====
FROM eclipse-temurin:17-jre-alpine
ENV APP_HOME=/app
WORKDIR ${APP_HOME}
# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring
COPY --from=build /workspace/target/*SNAPSHOT.jar app.jar
EXPOSE 3002
USER spring
ENTRYPOINT ["java","-XX:MaxRAMPercentage=75.0","-XX:+UseContainerSupport","-jar","/app/app.jar"]
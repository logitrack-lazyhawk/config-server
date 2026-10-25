# ==============================================================================
# Stage 1: Build stage
# ==============================================================================
FROM eclipse-temurin:25-jdk AS builder
WORKDIR /app

# Copy Maven wrapper configuration and project descriptor
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Normalize line endings for Linux execution and grant execution permissions
RUN sed -i 's/\r$//' ./mvnw && chmod +x ./mvnw

# Pre-fetch project dependencies for layer caching
RUN ./mvnw dependency:go-offline -B

# Copy application source code and compile/package the JAR
COPY src ./src
RUN ./mvnw clean package -DskipTests

# ==============================================================================
# Stage 2: Runtime stage
# ==============================================================================
FROM eclipse-temurin:25-jre
WORKDIR /app

# Create a non-root group and user for security compliance
RUN groupadd -r appgroup && useradd -r -g appgroup -d /app -s /sbin/nologin appuser

# Copy the built executable JAR from builder stage
COPY --from=builder /app/target/config-server-*.jar app.jar

# Set ownership to unprivileged user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Spring Cloud Config Server runs on port 8085
EXPOSE 8085

# Java options with container memory awareness and fast entropy source
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]

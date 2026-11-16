# Stage 1: Build
FROM maven:3.9-eclipse-temurin-21-alpine AS builder
WORKDIR /app

# Cache dependencies layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Build application
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime (slim JRE 21)
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create a non-root group and user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built application with ownership assigned to appuser
COPY --from=builder --chown=appuser:appgroup /app/target/app.jar app.jar

# Switch to non-root user
USER appuser

# Render sets PORT environment variable (default 10000 on Render)
ENV PORT=10000
EXPOSE ${PORT}

# Honor Render's PORT and map separate DB environment variables if present
ENTRYPOINT ["sh", "-c", "if [ -n \"$DB_HOST\" ] && [ -z \"$SPRING_DATASOURCE_URL\" ]; then export SPRING_DATASOURCE_URL=\"jdbc:postgresql://${DB_HOST}:${DB_PORT:-5432}/${DB_NAME}\"; fi && if [ -n \"$DB_USER\" ] && [ -z \"$SPRING_DATASOURCE_USERNAME\" ]; then export SPRING_DATASOURCE_USERNAME=\"${DB_USER}\"; fi && if [ -n \"$DB_PASSWORD\" ] && [ -z \"$SPRING_DATASOURCE_PASSWORD\" ]; then export SPRING_DATASOURCE_PASSWORD=\"${DB_PASSWORD}\"; fi && exec java $JAVA_OPTS -Dserver.port=${PORT} -jar app.jar"]

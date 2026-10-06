# ============================================================
# Padi da Parama! - Production Multi-Stage Dockerfile
# Stage 1: Build WAR with Maven
# Stage 2: Serve with Apache Tomcat 10.1 (Jakarta EE 10)
# ============================================================

FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy dependency definition and source
COPY pom.xml .
COPY src ./src

# Build production WAR
RUN mvn clean package -DskipTests

# Runtime stage with official Tomcat 10.1
FROM tomcat:10.1.24-jdk17-temurin

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy as ROOT application (accessible at root '/')
COPY --from=builder /app/target/student-life-manager.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]

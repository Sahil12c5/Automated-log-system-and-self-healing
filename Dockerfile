# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy the pom.xml and source code
COPY pom.xml .
COPY src ./src

# Build the WAR file (this will also trigger the assembly plugin to build log-agent.jar)
RUN mvn clean package -DskipTests

# Stage 2: Deploy to Tomcat
# Using Tomcat 9 because the project uses javax.servlet API (Servlet 4.0), not jakarta
FROM tomcat:9.0-jdk17

# Remove default Tomcat applications to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR file from the build stage to Tomcat's webapps directory
# Renaming to ROOT.war so it serves at the root context (/)
COPY --from=build /app/target/autoheal-platform.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

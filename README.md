# Automated Log System & Self-Healing Platform (Phase 1)

This project is a multi-tenant SaaS application built with strict MVC architectural patterns in Java. It allows organizations to register, manage their service domains, and in future phases, automatically ingest logs and self-heal applications.

## Prerequisites
- Java JDK 17+
- Apache Maven 3.8+
- MySQL 8.0+

## Database Initialization
1. Ensure your MySQL server is running.
2. Open your MySQL client or CLI.
3. Execute the `schema.sql` script located in `src/main/resources/schema.sql`:
   ```bash
   mysql -u root -p < src/main/resources/schema.sql
   ```
   This will create the `autoheal_db` database, all necessary tables for Phase 1 and 2, and insert seed data.

## Running the Application Locally
This project uses the Maven Jetty Plugin for easy embedded local development. 
To start the application:

1. Open a terminal in the project root directory.
2. Run the following command:
   ```bash
   mvn clean install jetty:run
   ```
3. Once the server starts, open your web browser and navigate to:
   **http://localhost:8080**

## Project Structure (Strict MVC)
- **Model**: `com.autoheal.model.*` (POJOs representing DB Entities)
- **DAO**: `com.autoheal.dao.*` (Data Access Objects executing JDBC queries)
- **Controller**: `com.autoheal.controller.*` (Java Servlets handling HTTP Routing)
- **View**: `src/main/webapp/` (JSP pages, CSS, JS, Bootstrap 5 UI)

## Phase 1 Features Available
- Organization & Owner Registration (with Password Strength Meter).
- Owner Password Login & Employee Passwordless OTP Login.
- Domain Registration (with Optional GitHub Integration).
- UUID API Key generation & mask toggles.
- Real-time client-side form validation.

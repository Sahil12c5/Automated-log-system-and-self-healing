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

---

## Log Agent Deployment & Cloud Integration Guide

To enable autonomous self-healing, each registered domain runs the lightweight `log-agent.jar` or pushes error events to `/api/v1/logs/ingest`.

### 1. Where to Add Your API Key
When you register a domain on the AutoHeal Dashboard, an API Key (`ahl_live_...`) is generated.
- **Render.com**: Dashboard &rarr; Service &rarr; **Environment** &rarr; Add `AUTOHEAL_API_KEY`
- **AWS (EC2 / Beanstalk)**: Inject in `.env`, `/etc/environment`, or Systemd unit file
- **Hostinger (VPS)**: PM2 configuration or `/etc/environment`
- **Vercel (Serverless)**: Project Settings &rarr; **Environment Variables** &rarr; Add `AUTOHEAL_API_KEY`
- **Docker**: `docker run -e AUTOHEAL_API_KEY="your_key"` or `docker-compose.yml`

---

### 2. Platform-Specific Setup

#### A. Render.com (Web Services & Background Workers)
1. **Build Command**:
   ```bash
   npm install && curl -sLO https://<AUTOHEAL_SERVER>/download/agent -o log-agent.jar
   ```
2. **Start Command**:
   ```bash
   java -jar log-agent.jar --api-key="$AUTOHEAL_API_KEY" --log-file="app.log" --server-url="https://<AUTOHEAL_SERVER>/api/v1/logs/ingest" & npm start
   ```

#### B. AWS (EC2 / Ubuntu / Linux VMs)
1. Install Java 17+:
   ```bash
   sudo apt update && sudo apt install -y openjdk-17-jre-headless
   ```
2. Download Agent:
   ```bash
   sudo mkdir -p /opt/autoheal && cd /opt/autoheal
   sudo curl -sLO https://<AUTOHEAL_SERVER>/download/agent -o log-agent.jar
   ```
3. Run as Systemd background service (`/etc/systemd/system/autoheal-agent.service`):
   ```ini
   [Unit]
   Description=AutoHeal Log Agent
   After=network.target

   [Service]
   Type=simple
   User=root
   WorkingDirectory=/opt/autoheal
   ExecStart=/usr/bin/java -jar /opt/autoheal/log-agent.jar --api-key="<YOUR_API_KEY>" --log-file="/var/log/app.log" --server-url="https://<AUTOHEAL_SERVER>/api/v1/logs/ingest"
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```
   Enable and start:
   ```bash
   sudo systemctl daemon-reload && sudo systemctl enable --now autoheal-agent
   ```

#### C. Hostinger (VPS & Cloud Hosting)
1. SSH into VPS:
   ```bash
   ssh root@<YOUR_HOSTINGER_VPS_IP>
   ```
2. Download Agent in your app directory:
   ```bash
   cd /var/www/your-app && curl -sLO https://<AUTOHEAL_SERVER>/download/agent -o log-agent.jar
   ```
3. Keep running with PM2:
   ```bash
   pm2 start "java -jar log-agent.jar --api-key='<YOUR_API_KEY>' --log-file='app.log' --server-url='https://<AUTOHEAL_SERVER>/api/v1/logs/ingest'" --name "autoheal-agent"
   pm2 save && pm2 startup
   ```

#### D. Vercel (Next.js & Serverless Functions)
Vercel runs ephemeral lambdas without a persistent JVM. Send uncaught errors directly via HTTP Ingestion:
```javascript
// lib/autoheal.js
export async function sendErrorToAutoHeal(error) {
  try {
    await fetch('https://<AUTOHEAL_SERVER>/api/v1/logs/ingest', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': process.env.AUTOHEAL_API_KEY
      },
      body: JSON.stringify({
        logLevel: 'ERROR',
        message: error.message || String(error),
        stackTrace: error.stack || null,
        timestamp: Date.now()
      })
    });
  } catch (err) {
    console.error('Failed to notify AutoHeal:', err);
  }
}
```

#### E. Docker & Containers
Run agent as a sidecar or within the same container sharing a volume:
```bash
docker run -d --name autoheal-agent \
  --restart unless-stopped \
  -v /var/log/app:/app/logs \
  -e AUTOHEAL_API_KEY="<YOUR_API_KEY>" \
  openjdk:17-slim \
  sh -c "curl -sLO https://<AUTOHEAL_SERVER>/download/agent -o /log-agent.jar && java -jar /log-agent.jar --api-key=\"$AUTOHEAL_API_KEY\" --log-file=\"/app/logs/app.log\" --server-url=\"https://<AUTOHEAL_SERVER>/api/v1/logs/ingest\""
```


package com.autoheal.util;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashSet;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Automatically bootstraps required database schemas and standard self-healing rules
 * upon application startup, ensuring cloud deployments (Aiven/Render) are always synchronized.
 */
public class DatabaseBootstrap {

    private static final Logger LOGGER = Logger.getLogger(DatabaseBootstrap.class.getName());
    private static volatile boolean bootstrapped = false;

    private static final String[][] DEFAULT_RULES = {
        // 1. Database connection pool
        {"Connection pool exhausted", "RESET_CONNECTION", "echo \"Resetting DB Connections\""},
        {"ERR_DB_POOL_EXHAUSTED", "RESET_CONNECTION", "echo \"Resetting DB Connections\""},
        {"DATABASE_ERROR", "RESET_CONNECTION", "echo \"Resetting DB Connections\""},

        // 2. Memory leak
        {"memory leak", "CLEAR_CACHE", "echo \"Clearing cache & freeing memory\""},
        {"OutOfMemoryError", "CLEAR_CACHE", "echo \"Clearing cache & freeing memory\""},
        {"ERR_HEAP_EXHAUSTED", "CLEAR_CACHE", "echo \"Clearing cache & freeing memory\""},
        {"MEMORY_LEAK", "CLEAR_CACHE", "echo \"Clearing cache & freeing memory\""},

        // 3. Redis cache
        {"RedisCacheException", "CLEAR_CACHE", "scripts/flush-redis-cache.sh"},
        {"ERR_REDIS_CONNECTION_REFUSED", "CLEAR_CACHE", "scripts/flush-redis-cache.sh"},
        {"CACHE_ERROR", "CLEAR_CACHE", "scripts/flush-redis-cache.sh"},

        // 4. Server freeze / deadlock
        {"freeze", "RESTART_SERVICE", "npm restart"},
        {"ServerThreadFrozen", "RESTART_SERVICE", "npm restart"},
        {"ServerFreezeException", "RESTART_SERVICE", "npm restart"},
        {"frozen", "RESTART_SERVICE", "npm restart"},
        {"ERR_EVENT_LOOP_DEADLOCK", "RESTART_SERVICE", "npm restart"},
        {"execution loop deadlock", "RESTART_SERVICE", "npm restart"},

        // 5. CPU lag / Event loop blocked / CPU starvation
        {"cpu lag", "RESTART_SERVICE", "pm2 restart app"},
        {"EventLoopBlocked", "RESTART_SERVICE", "pm2 restart app"},
        {"CPUStarvationException", "RESTART_SERVICE", "pm2 restart app"},
        {"CPUStarvation", "RESTART_SERVICE", "pm2 restart app"},
        {"CPU computation", "RESTART_SERVICE", "pm2 restart app"},
        {"blocking event loop", "RESTART_SERVICE", "pm2 restart app"},
        {"CPU starved", "RESTART_SERVICE", "pm2 restart app"},
        {"ERR_CPU_STARVATION", "RESTART_SERVICE", "pm2 restart app"},
        {"COMPUTE_SPIKE", "RESTART_SERVICE", "pm2 restart app"},

        // 6. Disk space / ENOSPC
        {"No space left on device", "CUSTOM_SCRIPT", "sh scripts/clear-disk-cache.sh"},
        {"ENOSPC", "CUSTOM_SCRIPT", "sh scripts/clear-disk-cache.sh"},
        {"STORAGE_CRITICAL", "CUSTOM_SCRIPT", "sh scripts/clear-disk-cache.sh"},
        {"DiskSpaceExhaustionError", "CUSTOM_SCRIPT", "sh scripts/clear-disk-cache.sh"},

        // 7. Gateway 502
        {"502 Bad Gateway", "RESTART_SERVICE", "pm2 restart backend-worker"},
        {"GATEWAY_ERROR", "RESTART_SERVICE", "pm2 restart backend-worker"},
        {"ERR_BAD_GATEWAY", "RESTART_SERVICE", "pm2 restart backend-worker"},
        {"BadGatewayError", "RESTART_SERVICE", "pm2 restart backend-worker"},

        // 8. EEXIST / Lockfile conflict
        {"EEXIST", "CUSTOM_SCRIPT", "rm -f /tmp/*.lock /var/run/*.pid"},
        {"file already exists", "CUSTOM_SCRIPT", "rm -f /tmp/*.lock /var/run/*.pid"},
        {"FILESYSTEM_CONFLICT", "CUSTOM_SCRIPT", "rm -f /tmp/*.lock /var/run/*.pid"},
        {"FileExistsConflict", "CUSTOM_SCRIPT", "rm -f /tmp/*.lock /var/run/*.pid"},

        // 9. EMFILE / Too many open files
        {"Too many open files", "CUSTOM_SCRIPT", "ulimit -n 65535 && pm2 reload all"},
        {"EMFILE", "CUSTOM_SCRIPT", "ulimit -n 65535 && pm2 reload all"},
        {"OS_RESOURCE_LIMIT", "CUSTOM_SCRIPT", "ulimit -n 65535 && pm2 reload all"},
        {"TooManyOpenFilesError", "CUSTOM_SCRIPT", "ulimit -n 65535 && pm2 reload all"},

        // 10. Zombie / Defunct process
        {"Defunct", "CUSTOM_SCRIPT", "pkill -9 -f defunct"},
        {"defunct", "CUSTOM_SCRIPT", "pkill -9 -f defunct"},
        {"ProcessZombieException", "CUSTOM_SCRIPT", "pkill -9 -f defunct"},
        {"PROCESS_CRITICAL", "CUSTOM_SCRIPT", "pkill -9 -f defunct"},
        {"ERR_PROCESS_DEFUNCT", "CUSTOM_SCRIPT", "pkill -9 -f defunct"},

        // 11. SSL / TLS Certificate Expired
        {"Certificate Expired", "CUSTOM_SCRIPT", "certbot renew && systemctl reload nginx"},
        {"certificate has expired", "CUSTOM_SCRIPT", "certbot renew && systemctl reload nginx"},
        {"CERT_HAS_EXPIRED", "CUSTOM_SCRIPT", "certbot renew && systemctl reload nginx"},
        {"TLSError", "CUSTOM_SCRIPT", "certbot renew && systemctl reload nginx"},
        {"SECURITY_ALERT", "CUSTOM_SCRIPT", "certbot renew && systemctl reload nginx"},
        {"CertificateExpiredError", "CUSTOM_SCRIPT", "certbot renew && systemctl reload nginx"}
    };

    public static synchronized void bootstrap(DataSource dataSource) {
        if (bootstrapped || dataSource == null) {
            return;
        }

        try (Connection conn = dataSource.getConnection()) {
            LOGGER.info("[DatabaseBootstrap] Checking and syncing auto-healing rules in database...");

            // 1. Ensure domain_id in auto_healing_rules is nullable for global rules
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("ALTER TABLE auto_healing_rules MODIFY domain_id BIGINT NULL");
            } catch (Exception e) {
                // Table might already have domain_id NULL or slight syntax variation
                LOGGER.fine("[DatabaseBootstrap] Alter table note: " + e.getMessage());
            }

            // 2. Ensure logs table status column supports all states (LOOP_DETECTED, SECURITY_BLOCKED, etc.) without truncation
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("ALTER TABLE logs MODIFY COLUMN status VARCHAR(50) NOT NULL DEFAULT 'PENDING'");
            } catch (Exception e) {
                LOGGER.fine("[DatabaseBootstrap] Alter logs status note: " + e.getMessage());
            }

            // 3. Ensure executed_action column can store detailed guardrail notes
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("ALTER TABLE logs MODIFY COLUMN executed_action TEXT NULL");
            } catch (Exception e) {
                LOGGER.fine("[DatabaseBootstrap] Alter logs executed_action note: " + e.getMessage());
            }

            // 4. Query existing error patterns (lowercase for case-insensitive comparison)
            Set<String> existingPatterns = new HashSet<>();
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT LOWER(error_pattern) FROM auto_healing_rules")) {
                while (rs.next()) {
                    existingPatterns.add(rs.getString(1));
                }
            }

            // 3. Insert any missing default rules
            String insertSql = "INSERT INTO auto_healing_rules (domain_id, error_pattern, action_type, target_script, is_active) VALUES (NULL, ?, ?, ?, 1)";
            int insertedCount = 0;

            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                for (String[] ruleDef : DEFAULT_RULES) {
                    String pattern = ruleDef[0];
                    String actionType = ruleDef[1];
                    String targetScript = ruleDef[2];

                    if (!existingPatterns.contains(pattern.toLowerCase())) {
                        insertStmt.setString(1, pattern);
                        insertStmt.setString(2, actionType);
                        insertStmt.setString(3, targetScript);
                        insertStmt.executeUpdate();
                        insertedCount++;
                        existingPatterns.add(pattern.toLowerCase());
                        LOGGER.info("[DatabaseBootstrap] Seeded default rule: '" + pattern + "' -> " + actionType);
                    }
                }
            }

            LOGGER.info("[DatabaseBootstrap] Rule sync complete. " + insertedCount + " new rules seeded.");
            bootstrapped = true;

        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[DatabaseBootstrap] Could not complete database bootstrap: " + e.getMessage(), e);
        }
    }
}

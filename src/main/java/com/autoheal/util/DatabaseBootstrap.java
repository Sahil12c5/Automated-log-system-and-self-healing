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
        {"Connection pool exhausted", "RESET_CONNECTION", "echo \"Resetting DB Connections\""},
        {"memory leak", "CLEAR_CACHE", "echo \"Clearing cache & freeing memory\""},
        {"RedisCacheException", "CLEAR_CACHE", "scripts/flush-redis-cache.sh"},
        {"freeze", "RESTART_SERVICE", "npm restart"},
        {"ServerThreadFrozen", "RESTART_SERVICE", "npm restart"},
        {"frozen", "RESTART_SERVICE", "npm restart"},
        {"cpu lag", "RESTART_SERVICE", "pm2 restart app"},
        {"502 Bad Gateway", "RESTART_SERVICE", "pm2 restart backend-worker"},
        {"Defunct", "CUSTOM_SCRIPT", "pkill -9 -f defunct"},
        {"Certificate Expired", "CUSTOM_SCRIPT", "certbot renew && systemctl reload nginx"},
        {"No space left on device", "CUSTOM_SCRIPT", "sh scripts/clear-disk-cache.sh"},
        {"ENOSPC", "CUSTOM_SCRIPT", "sh scripts/clear-disk-cache.sh"},
        {"STORAGE_CRITICAL", "CUSTOM_SCRIPT", "sh scripts/clear-disk-cache.sh"},
        {"EEXIST", "CUSTOM_SCRIPT", "rm -f /tmp/*.lock /var/run/*.pid"},
        {"FILESYSTEM_CONFLICT", "CUSTOM_SCRIPT", "rm -f /tmp/*.lock /var/run/*.pid"},
        {"Too many open files", "CUSTOM_SCRIPT", "ulimit -n 65535 && pm2 reload all"},
        {"EMFILE", "CUSTOM_SCRIPT", "ulimit -n 65535 && pm2 reload all"},
        {"OS_RESOURCE_LIMIT", "CUSTOM_SCRIPT", "ulimit -n 65535 && pm2 reload all"}
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

            // 2. Query existing error patterns (lowercase for case-insensitive comparison)
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

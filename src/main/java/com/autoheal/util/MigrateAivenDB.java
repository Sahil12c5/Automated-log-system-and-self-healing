package com.autoheal.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class MigrateAivenDB {
    public static void main(String[] args) {
        String url = "jdbc:mysql://error-generator-sahilchavan-ff75.h.aivencloud.com:15953/defaultdb?useSSL=true&requireSSL=true&allowPublicKeyRetrieval=true";
        String user = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "avnadmin";
        String pass = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "REMOVED_FOR_SECURITY";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Connecting to Aiven MySQL for migration...");
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 Statement stmt = conn.createStatement()) {

                System.out.println("Modifying domain_id to be nullable...");
                stmt.execute("ALTER TABLE auto_healing_rules MODIFY domain_id BIGINT NULL;");

                System.out.println("Inserting universal rules...");
                String insertSql = "INSERT INTO auto_healing_rules (domain_id, error_pattern, action_type, target_script, is_active) VALUES " +
                        "(NULL, 'Connection pool exhausted', 'RESET_CONNECTION', 'echo \"Resetting DB Connections\"', 1), " +
                        "(NULL, 'memory leak', 'CLEAR_CACHE', 'echo \"Clearing cache & freeing memory\"', 1), " +
                        "(NULL, 'RedisCacheException', 'CLEAR_CACHE', 'scripts/flush-redis-cache.sh', 1), " +
                        "(NULL, 'freeze', 'RESTART_SERVICE', 'npm restart', 1), " +
                        "(NULL, 'cpu lag', 'RESTART_SERVICE', 'pm2 restart app', 1), " +
                        "(NULL, 'No space left on device', 'CUSTOM_SCRIPT', 'cleanup-storage.sh', 1), " +
                        "(NULL, '502 Bad Gateway', 'RESTART_SERVICE', 'pm2 restart backend-worker', 1), " +
                        "(NULL, 'EEXIST', 'CUSTOM_SCRIPT', 'rm -f /tmp/*.lock', 1), " +
                        "(NULL, 'Too many open files', 'CUSTOM_SCRIPT', 'ulimit -n 65535 && pm2 reload all', 1), " +
                        "(NULL, 'Defunct', 'CUSTOM_SCRIPT', 'pkill -9 -f defunct', 1), " +
                        "(NULL, 'Certificate Expired', 'CUSTOM_SCRIPT', 'certbot renew && systemctl reload nginx', 1);";
                stmt.execute(insertSql);
                
                System.out.println("SUCCESS: Migration completed securely on Aiven database.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

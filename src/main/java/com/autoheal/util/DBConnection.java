package com.autoheal.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Logger;

public class DBConnection {
    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());
    private static HikariDataSource dataSource;
    private static Exception initException;

    static {
        initPool();
    }

    private static synchronized void initPool() {
        if (dataSource != null && !dataSource.isClosed()) {
            return;
        }
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            HikariConfig config = new HikariConfig();
            
            String jdbcUrl = System.getenv("DB_URL") != null ? System.getenv("DB_URL") : "jdbc:mysql://localhost:3306/autoheal_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
            String username = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";
            String password = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "";

            config.setJdbcUrl(jdbcUrl);
            config.setUsername(username);
            config.setPassword(password);

            // HikariCP Pool settings
            config.setMaximumPoolSize(15);
            config.setMinimumIdle(3);
            config.setIdleTimeout(300000); // 5 mins
            config.setConnectionTimeout(20000); // 20s
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

            dataSource = new HikariDataSource(config);
            initException = null;
            LOGGER.info("HikariCP Connection Pool initialized successfully.");
        } catch (Exception e) {
            initException = e;
            LOGGER.severe("Failed to initialize HikariCP DataSource: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null || dataSource.isClosed()) {
            // Attempt re-init in case DB was started after app load
            initPool();
        }
        if (dataSource == null) {
            String detail = initException != null ? initException.getMessage() : "Unknown error";
            throw new SQLException("HikariCP DataSource is not initialized. Root cause: " + detail, initException);
        }
        return dataSource.getConnection();
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}

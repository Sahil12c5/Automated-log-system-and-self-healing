package com.autoheal.dao;

import com.autoheal.model.LogEntry;
import com.autoheal.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LogDAO {

    public Long createLog(LogEntry log) throws SQLException {
        String sql = "INSERT INTO logs (domain_id, log_level, message, stack_trace, status, executed_action, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setLong(1, log.getDomainId());
            stmt.setString(2, log.getLogLevel());
            stmt.setString(3, log.getMessage());
            stmt.setString(4, log.getStackTrace());
            stmt.setString(5, log.getStatus());
            stmt.setString(6, log.getExecutedAction());
            
            if (log.getCreatedAt() != null) {
                stmt.setTimestamp(7, log.getCreatedAt());
            } else {
                stmt.setTimestamp(7, new java.sql.Timestamp(System.currentTimeMillis()));
            }

            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

    public List<LogEntry> findByOrganization(Long organizationId, Long domainId, String logLevel, String status, String searchQuery, int limit) throws SQLException {
        List<LogEntry> logs = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT l.id, l.domain_id, d.domain_name, l.log_level, l.message, l.stack_trace, l.status, l.executed_action, l.ai_root_cause, l.ai_remediation_suggestion, l.created_at " +
            "FROM logs l " +
            "JOIN domains d ON l.domain_id = d.id " +
            "WHERE d.organization_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(organizationId);

        if (domainId != null && domainId > 0) {
            sql.append("AND l.domain_id = ? ");
            params.add(domainId);
        }

        if (logLevel != null && !logLevel.trim().isEmpty() && !"ALL".equalsIgnoreCase(logLevel)) {
            sql.append("AND l.log_level = ? ");
            params.add(logLevel.trim().toUpperCase());
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append("AND l.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (l.message LIKE ? OR l.executed_action LIKE ?) ");
            String wild = "%" + searchQuery.trim() + "%";
            params.add(wild);
            params.add(wild);
        }

        sql.append("ORDER BY l.id DESC LIMIT ?");
        params.add(limit > 0 ? limit : 100);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    LogEntry entry = new LogEntry(
                        rs.getLong("id"),
                        rs.getLong("domain_id"),
                        rs.getString("log_level"),
                        rs.getString("message"),
                        rs.getString("stack_trace"),
                        rs.getString("status"),
                        rs.getString("executed_action"),
                        rs.getString("ai_root_cause"),
                        rs.getString("ai_remediation_suggestion"),
                        rs.getTimestamp("created_at")
                    );
                    entry.setDomainName(rs.getString("domain_name"));
                    logs.add(entry);
                }
            }
        }
        return logs;
    }

    public int countTotalLogsByOrganization(Long organizationId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM logs l JOIN domains d ON l.domain_id = d.id WHERE d.organization_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, organizationId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int countAutoHealedLogsByOrganization(Long organizationId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM logs l JOIN domains d ON l.domain_id = d.id WHERE d.organization_id = ? AND l.status = 'AUTO_HEALED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, organizationId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
    public LogEntry findById(Long id) throws SQLException {
        String sql = "SELECT l.id, l.domain_id, d.domain_name, l.log_level, l.message, l.stack_trace, l.status, l.executed_action, l.ai_root_cause, l.ai_remediation_suggestion, l.created_at " +
                     "FROM logs l JOIN domains d ON l.domain_id = d.id WHERE l.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    LogEntry entry = new LogEntry(
                        rs.getLong("id"),
                        rs.getLong("domain_id"),
                        rs.getString("log_level"),
                        rs.getString("message"),
                        rs.getString("stack_trace"),
                        rs.getString("status"),
                        rs.getString("executed_action"),
                        rs.getString("ai_root_cause"),
                        rs.getString("ai_remediation_suggestion"),
                        rs.getTimestamp("created_at")
                    );
                    entry.setDomainName(rs.getString("domain_name"));
                    return entry;
                }
            }
        }
        return null;
    }

    public boolean updateLogDiagnosis(Long id, String rootCause, String remediation, String status) throws SQLException {
        String sql = "UPDATE logs SET ai_root_cause = ?, ai_remediation_suggestion = ?, status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, rootCause);
            stmt.setString(2, remediation);
            stmt.setString(3, status);
            stmt.setLong(4, id);
            return stmt.executeUpdate() > 0;
        }
    }
}

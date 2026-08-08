package com.autoheal.dao;

import com.autoheal.model.AuditLog;
import com.autoheal.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAO {

    public void logAction(Long organizationId, Long userId, String action, String details) throws SQLException {
        String sql = "INSERT INTO audit_logs (organization_id, user_id, action, details) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, organizationId);
            if (userId != null) {
                stmt.setLong(2, userId);
            } else {
                stmt.setNull(2, Types.BIGINT);
            }
            stmt.setString(3, action);
            stmt.setString(4, details);
            stmt.executeUpdate();
        }
    }

    public List<AuditLog> findRecentByOrganizationId(Long organizationId, int limit) throws SQLException {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT id, organization_id, user_id, action, details, created_at FROM audit_logs WHERE organization_id = ? ORDER BY id DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, organizationId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(new AuditLog(
                        rs.getLong("id"),
                        rs.getLong("organization_id"),
                        rs.getObject("user_id") != null ? rs.getLong("user_id") : null,
                        rs.getString("action"),
                        rs.getString("details"),
                        rs.getTimestamp("created_at")
                    ));
                }
            }
        }
        return logs;
    }
}

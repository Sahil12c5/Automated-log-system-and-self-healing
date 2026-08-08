package com.autoheal.dao;

import com.autoheal.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDomainScopeDAO {

    public void addScope(Long userId, Long domainId) throws SQLException {
        String sql = "INSERT INTO user_domain_scopes (user_id, domain_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE domain_id=domain_id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.setLong(2, domainId);
            stmt.executeUpdate();
        }
    }

    public void removeScope(Long userId, Long domainId) throws SQLException {
        String sql = "DELETE FROM user_domain_scopes WHERE user_id = ? AND domain_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.setLong(2, domainId);
            stmt.executeUpdate();
        }
    }

    public void clearScopesForUser(Long userId) throws SQLException {
        String sql = "DELETE FROM user_domain_scopes WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.executeUpdate();
        }
    }

    public List<Long> getDomainIdsForUser(Long userId) throws SQLException {
        List<Long> domainIds = new ArrayList<>();
        String sql = "SELECT domain_id FROM user_domain_scopes WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    domainIds.add(rs.getLong("domain_id"));
                }
            }
        }
        return domainIds;
    }
}

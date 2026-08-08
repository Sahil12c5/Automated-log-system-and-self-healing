package com.autoheal.dao;

import com.autoheal.model.Organization;
import com.autoheal.util.DBConnection;

import java.sql.*;

public class OrganizationDAO {

    public Long createOrganization(String name) throws SQLException {
        String sql = "INSERT INTO organizations (name) VALUES (?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, name);
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

    public Organization findById(Long id) throws SQLException {
        String sql = "SELECT id, name, created_at FROM organizations WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Organization(
                        rs.getLong("id"),
                        rs.getString("name"),
                        rs.getTimestamp("created_at")
                    );
                }
            }
        }
        return null;
    }

    public Organization findByName(String name) throws SQLException {
        String sql = "SELECT id, name, created_at FROM organizations WHERE name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Organization(
                        rs.getLong("id"),
                        rs.getString("name"),
                        rs.getTimestamp("created_at")
                    );
                }
            }
        }
        return null;
    }
}

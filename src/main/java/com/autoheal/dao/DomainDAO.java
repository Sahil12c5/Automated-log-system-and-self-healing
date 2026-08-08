package com.autoheal.dao;

import com.autoheal.model.Domain;
import com.autoheal.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DomainDAO {

    public Long createDomain(Domain domain) throws SQLException {
        String sql = "INSERT INTO domains (organization_id, domain_name, api_key, github_repo, github_token) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setLong(1, domain.getOrganizationId());
            stmt.setString(2, domain.getDomainName());
            stmt.setString(3, domain.getApiKey());
            stmt.setString(4, domain.getGithubRepo());
            stmt.setString(5, domain.getGithubToken());

            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

    public List<Domain> findByOrganizationId(Long organizationId) throws SQLException {
        List<Domain> domains = new ArrayList<>();
        String sql = "SELECT id, organization_id, domain_name, api_key, github_repo, github_token, created_at FROM domains WHERE organization_id = ? ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, organizationId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    domains.add(new Domain(
                        rs.getLong("id"),
                        rs.getLong("organization_id"),
                        rs.getString("domain_name"),
                        rs.getString("api_key"),
                        rs.getString("github_repo"),
                        rs.getString("github_token"),
                        rs.getTimestamp("created_at")
                    ));
                }
            }
        }
        return domains;
    }

    public boolean deleteDomain(Long id, Long organizationId) throws SQLException {
        String sql = "DELETE FROM domains WHERE id = ? AND organization_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            stmt.setLong(2, organizationId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean isDomainExists(Long organizationId, String domainName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM domains WHERE organization_id = ? AND domain_name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, organizationId);
            stmt.setString(2, domainName);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public int countByOrganizationId(Long organizationId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM domains WHERE organization_id = ?";
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

    public Domain findById(Long id) throws SQLException {
        String sql = "SELECT id, organization_id, domain_name, api_key, github_repo, github_token, created_at FROM domains WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Domain(
                        rs.getLong("id"),
                        rs.getLong("organization_id"),
                        rs.getString("domain_name"),
                        rs.getString("api_key"),
                        rs.getString("github_repo"),
                        rs.getString("github_token"),
                        rs.getTimestamp("created_at")
                    );
                }
            }
        }
        return null;
    }

    public Domain findByApiKey(String apiKey) throws SQLException {
        String sql = "SELECT id, organization_id, domain_name, api_key, github_repo, github_token, created_at FROM domains WHERE api_key = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, apiKey);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Domain(
                        rs.getLong("id"),
                        rs.getLong("organization_id"),
                        rs.getString("domain_name"),
                        rs.getString("api_key"),
                        rs.getString("github_repo"),
                        rs.getString("github_token"),
                        rs.getTimestamp("created_at")
                    );
                }
            }
        }
        return null;
    }
}

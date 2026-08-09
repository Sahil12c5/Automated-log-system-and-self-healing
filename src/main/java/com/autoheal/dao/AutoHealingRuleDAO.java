package com.autoheal.dao;

import com.autoheal.model.AutoHealingRule;
import com.autoheal.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AutoHealingRuleDAO {

    public Long createRule(AutoHealingRule rule) throws SQLException {
        String sql = "INSERT INTO auto_healing_rules (domain_id, error_pattern, action_type, target_script, is_active) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setObject(1, rule.getDomainId(), Types.BIGINT);
            stmt.setString(2, rule.getErrorPattern());
            stmt.setString(3, rule.getActionType());
            stmt.setString(4, rule.getTargetScript());
            stmt.setBoolean(5, rule.isActive());

            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

    public List<AutoHealingRule> findActiveRulesByDomainId(Long domainId) throws SQLException {
        List<AutoHealingRule> rules = new ArrayList<>();
        String sql = "SELECT id, domain_id, error_pattern, action_type, target_script, is_active, created_at FROM auto_healing_rules WHERE (domain_id = ? OR domain_id IS NULL) AND is_active = 1 ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, domainId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    rules.add(extractRuleFromResultSet(rs));
                }
            }
        }
        return rules;
    }

    public List<AutoHealingRule> findByOrganizationId(Long organizationId) throws SQLException {
        List<AutoHealingRule> rules = new ArrayList<>();
        String sql = "SELECT r.id, r.domain_id, d.domain_name, r.error_pattern, r.action_type, r.target_script, r.is_active, r.created_at " +
                     "FROM auto_healing_rules r " +
                     "JOIN domains d ON r.domain_id = d.id " +
                     "WHERE d.organization_id = ? ORDER BY r.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, organizationId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    AutoHealingRule rule = extractRuleFromResultSet(rs);
                    rule.setDomainName(rs.getString("domain_name"));
                    rules.add(rule);
                }
            }
        }
        return rules;
    }

    public boolean toggleRuleActive(Long ruleId, Long organizationId, boolean isActive) throws SQLException {
        String sql = "UPDATE auto_healing_rules r " +
                     "JOIN domains d ON r.domain_id = d.id " +
                     "SET r.is_active = ? " +
                     "WHERE r.id = ? AND d.organization_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBoolean(1, isActive);
            stmt.setLong(2, ruleId);
            stmt.setLong(3, organizationId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean deleteRule(Long ruleId, Long organizationId) throws SQLException {
        String sql = "DELETE r FROM auto_healing_rules r " +
                     "JOIN domains d ON r.domain_id = d.id " +
                     "WHERE r.id = ? AND d.organization_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, ruleId);
            stmt.setLong(2, organizationId);
            return stmt.executeUpdate() > 0;
        }
    }

    private AutoHealingRule extractRuleFromResultSet(ResultSet rs) throws SQLException {
        Long domainId = (Long) rs.getObject("domain_id");
        return new AutoHealingRule(
            rs.getLong("id"),
            domainId,
            rs.getString("error_pattern"),
            rs.getString("action_type"),
            rs.getString("target_script"),
            rs.getBoolean("is_active"),
            rs.getTimestamp("created_at")
        );
    }
}

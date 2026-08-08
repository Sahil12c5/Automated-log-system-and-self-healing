package com.autoheal.util;

import java.sql.Connection;
import java.sql.Statement;

public class DBUpdater {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            String sql = "ALTER TABLE logs ADD COLUMN IF NOT EXISTS ai_root_cause TEXT NULL AFTER executed_action, ADD COLUMN IF NOT EXISTS ai_remediation_suggestion TEXT NULL AFTER ai_root_cause;";
            stmt.executeUpdate(sql);
            System.out.println("SUCCESS: Database schema updated with AI fields.");
            
        } catch (Exception e) {
            System.err.println("FAILED: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBConnection.closePool();
        }
    }
}

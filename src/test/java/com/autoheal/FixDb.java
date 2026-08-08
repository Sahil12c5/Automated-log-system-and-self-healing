package com.autoheal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class FixDb {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/autoheal_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC", "root", "")) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute("ALTER TABLE domains ADD COLUMN github_repo VARCHAR(255) NULL");
                    System.out.println("Added github_repo");
                } catch(Exception e) { System.out.println(e.getMessage()); }
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute("ALTER TABLE domains ADD COLUMN github_token VARCHAR(255) NULL");
                    System.out.println("Added github_token");
                } catch(Exception e) { System.out.println(e.getMessage()); }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

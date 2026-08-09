package com.autoheal.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.nio.file.Files;
import java.nio.file.Paths;

public class InitAivenDB {
    public static void main(String[] args) {
        String url = "jdbc:mysql://error-generator-sahilchavan-ff75.h.aivencloud.com:15953/defaultdb?useSSL=true&requireSSL=true&allowPublicKeyRetrieval=true";
        String user = "avnadmin";
        String pass = "REMOVED_FOR_SECURITY";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Connecting to Aiven MySQL...");
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 Statement stmt = conn.createStatement()) {

                System.out.println("Connected! Reading schema.sql...");
                String content = new String(Files.readAllBytes(Paths.get("src/main/resources/schema.sql")));
                
                // Remove comments and split by ;
                String[] queries = content.replaceAll("--.*", "").split(";");
                
                for (String query : queries) {
                    if (query.trim().isEmpty()) continue;
                    System.out.println("Executing: " + query.trim().substring(0, Math.min(query.trim().length(), 50)) + "...");
                    stmt.execute(query.trim());
                }
                
                System.out.println("SUCCESS: All tables created in Aiven database.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

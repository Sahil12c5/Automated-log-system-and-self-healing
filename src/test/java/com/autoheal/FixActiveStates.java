package com.autoheal;

import java.nio.file.*;
import java.io.IOException;

public class FixActiveStates {
    public static void main(String[] args) throws IOException {
        String baseDir = "c:/Users/sahil/OneDrive/Desktop/Major project/src/main/webapp/";
        String[] files = {"dashboard.jsp", "logs.jsp", "rules.jsp", "diagnostics.jsp", "approvals.jsp", "team.jsp", "audit.jsp", "guardrails.jsp", "simulation.jsp"};

        for (String file : files) {
            Path path = Paths.get(baseDir + file);
            if (!Files.exists(path)) continue;

            String content = new String(Files.readAllBytes(path));

            // First, reset all navbar buttons to outline
            content = content.replace("class=\"btn btn-sm btn-saas-primary\"", "class=\"btn btn-sm btn-saas-outline border-0\"");
            content = content.replace("class=\"btn btn-sm btn-saas-primary dropdown-toggle\"", "class=\"btn btn-sm btn-saas-outline border-0 dropdown-toggle\"");

            // Then set the specific one to primary based on the file
            String target = "";
            if (file.equals("dashboard.jsp")) {
                target = "<i class=\"bi bi-speedometer2 me-1\"></i> Dashboard";
            } else if (file.equals("logs.jsp")) {
                target = "<i class=\"bi bi-terminal-fill me-1\"></i> Live Logs";
            } else if (file.equals("rules.jsp")) {
                target = "<i class=\"bi bi-magic me-1\"></i> Healing Rules";
            } else if (file.equals("diagnostics.jsp") || file.equals("approvals.jsp")) {
                target = "<i class=\"bi bi-robot me-1\"></i> AI Engine";
            } else if (file.equals("team.jsp") || file.equals("audit.jsp") || file.equals("guardrails.jsp") || file.equals("simulation.jsp")) {
                target = "<i class=\"bi bi-shield-lock me-1\"></i> Admin";
            }

            if (!target.isEmpty()) {
                // Find the line containing the target and replace the class of the enclosing anchor/button
                String[] lines = content.split("\n");
                for (int i = 0; i < lines.length; i++) {
                    if (lines[i].contains(target)) {
                        // The button class might be on the same line or previous line
                        if (lines[i].contains("btn-saas-outline")) {
                            lines[i] = lines[i].replace("btn-saas-outline border-0", "btn-saas-primary");
                        } else if (i > 0 && lines[i-1].contains("btn-saas-outline")) {
                            lines[i-1] = lines[i-1].replace("btn-saas-outline border-0", "btn-saas-primary");
                        }
                    }
                }
                content = String.join("\n", lines);
            }

            Files.write(path, content.getBytes());
            System.out.println("Processed " + file);
        }
    }
}

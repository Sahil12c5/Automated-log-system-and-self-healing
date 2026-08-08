package com.autoheal.controller;

import com.autoheal.dao.AuditLogDAO;
import com.autoheal.dao.AutoHealingRuleDAO;
import com.autoheal.dao.DomainDAO;
import com.autoheal.dao.LogDAO;
import com.autoheal.model.AutoHealingRule;
import com.autoheal.model.Domain;
import com.autoheal.model.LogEntry;
import com.autoheal.guardrail.CommandSanitizer;
import com.autoheal.guardrail.RateLimiter;
import com.autoheal.util.JSONUtil;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/v1/logs/ingest")
public class LogIngestionServlet extends HttpServlet {

    private final DomainDAO domainDAO = new DomainDAO();
    private final AutoHealingRuleDAO ruleDAO = new AutoHealingRuleDAO();
    private final LogDAO logDAO = new LogDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 1. Authenticate via X-API-KEY header
        String apiKey = req.getHeader("X-API-KEY");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            apiKey = req.getParameter("api_key"); // Fallback query parameter
        }

        if (apiKey == null || apiKey.trim().isEmpty()) {
            JSONUtil.sendJsonResponse(resp, 401, false, "Unauthorized: Missing X-API-KEY header.", null);
            return;
        }

        try {
            Domain domain = domainDAO.findByApiKey(apiKey.trim());
            if (domain == null) {
                JSONUtil.sendJsonResponse(resp, 401, false, "Unauthorized: Invalid API Key.", null);
                return;
            }

            // 2. Read JSON Request Body
            StringBuilder buffer = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    buffer.append(line);
                }
            }

            String jsonString = buffer.toString();
            if (jsonString.trim().isEmpty()) {
                JSONUtil.sendJsonResponse(resp, 400, false, "Empty request body.", null);
                return;
            }

            JsonObject jsonObject;
            try {
                jsonObject = JsonParser.parseString(jsonString).getAsJsonObject();
            } catch (Exception e) {
                JSONUtil.sendJsonResponse(resp, 400, false, "Invalid JSON payload: " + e.getMessage(), null);
                return;
            }

            String logLevel = jsonObject.has("logLevel") ? jsonObject.get("logLevel").getAsString().toUpperCase() : "INFO";
            String message = jsonObject.has("message") ? jsonObject.get("message").getAsString() : "";
            String stackTrace = jsonObject.has("stackTrace") && !jsonObject.get("stackTrace").isJsonNull() 
                                ? jsonObject.get("stackTrace").getAsString() : null;
            long timestamp = jsonObject.has("timestamp") ? jsonObject.get("timestamp").getAsLong() : System.currentTimeMillis();

            if (message == null || message.trim().isEmpty()) {
                JSONUtil.sendJsonResponse(resp, 400, false, "Log message is required.", null);
                return;
            }

            // Standardize log levels
            if (!logLevel.matches("^(INFO|WARN|ERROR|CRITICAL)$")) {
                logLevel = "INFO";
            }

            // 3. Auto-Healing Rule Engine Evaluation
            String status = "PENDING";
            String executedAction = null;

            List<AutoHealingRule> activeRules = ruleDAO.findActiveRulesByDomainId(domain.getId());
            for (AutoHealingRule rule : activeRules) {
                String pattern = rule.getErrorPattern().toLowerCase();
                String msgLower = message.toLowerCase();
                String traceLower = (stackTrace != null) ? stackTrace.toLowerCase() : "";

                if (msgLower.contains(pattern) || traceLower.contains(pattern)) {
                    // Match found! Phase 5: Rate Limiter Check
                    if (RateLimiter.isLoopDetected(domain.getId())) {
                        status = "LOOP_DETECTED";
                        executedAction = "GUARDRAIL_BLOCKED: Auto-fix loop detected (>3 times in 15m)";
                        break;
                    }
                    
                    // Apply CommandSanitizer check
                    if (!CommandSanitizer.isSafe(rule.getTargetScript())) {
                        status = "SECURITY_BLOCKED";
                        executedAction = "REJECTED_BY_SECURITY: Script contains blacklisted command";
                        break;
                    }
                    
                    status = "AUTO_HEALED";
                    executedAction = rule.getActionType() + ": " + rule.getTargetScript();
                    RateLimiter.recordExecution(domain.getId());

                    auditLogDAO.logAction(
                        domain.getOrganizationId(), 
                        null, 
                        "AUTO_HEALING_EXECUTED", 
                        "Rule #" + rule.getId() + " (" + rule.getActionType() + ") triggered for error pattern '" + rule.getErrorPattern() + "' on domain " + domain.getDomainName()
                    );
                    break; // Execute first matching active rule
                }
            }

            // 4. Save Log Entry to Database
            LogEntry logEntry = new LogEntry();
            logEntry.setDomainId(domain.getId());
            logEntry.setLogLevel(logLevel);
            logEntry.setMessage(message);
            logEntry.setStackTrace(stackTrace);
            logEntry.setStatus(status);
            logEntry.setExecutedAction(executedAction);
            logEntry.setCreatedAt(new java.sql.Timestamp(timestamp));

            Long logId = logDAO.createLog(logEntry);
            logEntry.setId(logId);
            logEntry.setDomainName(domain.getDomainName());

            // 5. Return JSON Response
            Map<String, Object> jsonMap = new HashMap<>();
            jsonMap.put("success", true);
            jsonMap.put("message", "Log entry ingested successfully.");
            jsonMap.put("logId", logId);
            jsonMap.put("domainName", domain.getDomainName());
            jsonMap.put("logLevel", logLevel);
            jsonMap.put("status", status);
            jsonMap.put("executedAction", executedAction);

            if ("AUTO_HEALED".equals(status)) {
                // Find the rule target script that was executed
                for (AutoHealingRule rule : activeRules) {
                    if (executedAction != null && executedAction.contains(rule.getTargetScript())) {
                        jsonMap.put("commands", new String[]{ rule.getTargetScript() });
                        break;
                    }
                }
            }

            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.setStatus(200);
            resp.getWriter().print(new com.google.gson.GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").create().toJson(jsonMap));
            resp.getWriter().flush();

        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Ingestion error: " + e.getMessage(), null);
        }
    }
}

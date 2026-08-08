package com.autoheal.controller;

import com.autoheal.dao.AuditLogDAO;
import com.autoheal.dao.AutoHealingRuleDAO;
import com.autoheal.dao.DomainDAO;
import com.autoheal.dao.LogDAO;
import com.autoheal.guardrail.CommandSanitizer;
import com.autoheal.guardrail.RateLimiter;
import com.autoheal.model.AutoHealingRule;
import com.autoheal.model.Domain;
import com.autoheal.model.LogEntry;
import com.autoheal.model.User;
import com.autoheal.service.GitHubIntegrationService;
import com.autoheal.service.RuleConversionService;
import com.autoheal.util.JSONUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

@WebServlet(urlPatterns = {"/api/v1/logs/approve"})
public class ApprovalServlet extends HttpServlet {

    private final LogDAO logDAO = new LogDAO();
    private final AutoHealingRuleDAO ruleDAO = new AutoHealingRuleDAO();
    private final AuditLogDAO auditDAO = new AuditLogDAO();
    private final DomainDAO domainDAO = new DomainDAO();
    private final GitHubIntegrationService githubService = new GitHubIntegrationService();
    private final RuleConversionService ruleConversionService = new RuleConversionService();
    private final Gson gson = new Gson();
    private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder()
            .version(HttpClient.Version.HTTP_2)
            .connectTimeout(Duration.ofSeconds(5))
            .build();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");

        try {
            BufferedReader reader = req.getReader();
            JsonObject requestBody = gson.fromJson(reader, JsonObject.class);
            if (requestBody == null || !requestBody.has("logId") || !requestBody.has("action")) {
                JSONUtil.sendJsonResponse(resp, 400, false, "Missing logId or action.", null);
                return;
            }

            Long logId = requestBody.get("logId").getAsLong();
            String action = requestBody.get("action").getAsString(); // APPROVE, PERMANENT_RULE, REJECT
            LogEntry log = logDAO.findById(logId);
            
            if (log == null) {
                JSONUtil.sendJsonResponse(resp, 404, false, "Log not found.", null);
                return;
            }

            if ("REJECT".equals(action)) {
                logDAO.updateLogDiagnosis(logId, log.getAiRootCause(), log.getAiRemediationSuggestion(), "REJECTED");
                auditDAO.logAction(user.getOrganizationId(), user.getId(), "AI_REJECTED", "Rejected AI fix for log ID: " + logId);
                JSONUtil.sendJsonResponse(resp, 200, true, "AI suggestion rejected.", null);
            } 
            else if ("APPROVE".equals(action)) {
                String aiSuggestion = log.getAiRemediationSuggestion() != null ? log.getAiRemediationSuggestion() : "";
                Domain domain = domainDAO.findById(log.getDomainId());
                
                if (domain == null) {
                    JSONUtil.sendJsonResponse(resp, 404, false, "Domain associated with this log not found.", null);
                    return;
                }

                // Heuristic: Check if the AI suggestion contains code diff indicators
                boolean isSourceCodeFix = aiSuggestion.contains("```diff") || aiSuggestion.contains("diff --git");

                // --- PHASE 5 GUARDRAILS ---
                if (RateLimiter.isLoopDetected(log.getDomainId())) {
                    logDAO.updateLogDiagnosis(logId, log.getAiRootCause(), log.getAiRemediationSuggestion(), "LOOP_DETECTED");
                    auditDAO.logAction(user.getOrganizationId(), user.getId(), "GUARDRAIL_BLOCKED", "Loop detected. Automated fix blocked for log ID: " + logId);
                    JSONUtil.sendJsonResponse(resp, 403, false, "Execution blocked by Guardrail: Rate limit exceeded (Loop Detected).", null);
                    return;
                }
                
                if (!isSourceCodeFix && !CommandSanitizer.isSafe(aiSuggestion)) {
                    logDAO.updateLogDiagnosis(logId, log.getAiRootCause(), log.getAiRemediationSuggestion(), "SECURITY_BLOCKED");
                    auditDAO.logAction(user.getOrganizationId(), user.getId(), "GUARDRAIL_BLOCKED", "Unsafe command detected. Execution blocked for log ID: " + logId);
                    JSONUtil.sendJsonResponse(resp, 403, false, "Execution blocked by Guardrail: Blacklisted command detected.", null);
                    return;
                }

                if (isSourceCodeFix) {
                    try {
                        System.out.println("Executing GitHub Source Code Fix for log " + logId + "...");
                        githubService.executeSourceCodeFix(domain.getGithubRepo(), domain.getGithubToken(), logId, aiSuggestion);
                        RateLimiter.recordExecution(log.getDomainId());
                        auditDAO.logAction(user.getOrganizationId(), user.getId(), "AI_APPROVED_SOURCE", "Executed GitHub Hotfix PR for log ID: " + logId);
                    } catch (Exception e) {
                        e.printStackTrace();
                        JSONUtil.sendJsonResponse(resp, 500, false, "GitHub Hotfix execution failed: " + e.getMessage(), null);
                        return;
                    }
                } else {
                    // Operational fix: Send Webhook to client agent
                    System.out.println("Executing Operational Fix Webhook for log " + logId + "...");
                    try {
                        JsonObject payload = new JsonObject();
                        payload.addProperty("logId", logId);
                        payload.addProperty("script", aiSuggestion);

                        HttpRequest request = HttpRequest.newBuilder()
                                .uri(URI.create("http://client-agent.internal/api/webhook/execute"))
                                .header("Content-Type", "application/json")
                                .POST(HttpRequest.BodyPublishers.ofString(gson.toJson(payload)))
                                .build();
                        
                        try {
                            HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
                        } catch (Exception e) {
                            System.out.println("Webhook delivery simulated (Mock URL failed as expected).");
                        }
                        
                        RateLimiter.recordExecution(log.getDomainId());
                        auditDAO.logAction(user.getOrganizationId(), user.getId(), "AI_APPROVED_OPERATIONAL", "Executed Agent Webhook for log ID: " + logId);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                
                logDAO.updateLogDiagnosis(logId, log.getAiRootCause(), log.getAiRemediationSuggestion(), "APPROVED");
                JSONUtil.sendJsonResponse(resp, 200, true, "Fix approved and executed successfully.", null);
            }
            else if ("PERMANENT_RULE".equals(action)) {
                System.out.println("Creating permanent rule for log " + logId + "...");
                
                boolean created = ruleConversionService.convertToPermanentRule(log);
                if (created) {
                    logDAO.updateLogDiagnosis(logId, log.getAiRootCause(), log.getAiRemediationSuggestion(), "APPROVED");
                    auditDAO.logAction(user.getOrganizationId(), user.getId(), "AI_PERMANENT_RULE", "Approved AI fix and created permanent rule for log ID: " + logId);
                    JSONUtil.sendJsonResponse(resp, 200, true, "Permanent auto-healing rule successfully established.", null);
                } else {
                    JSONUtil.sendJsonResponse(resp, 500, false, "Failed to create permanent rule.", null);
                }
            } else {
                JSONUtil.sendJsonResponse(resp, 400, false, "Invalid action.", null);
            }
        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Error processing approval: " + e.getMessage(), null);
        }
    }
}

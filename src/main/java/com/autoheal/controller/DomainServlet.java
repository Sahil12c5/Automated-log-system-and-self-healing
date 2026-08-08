package com.autoheal.controller;

import com.autoheal.dao.AuditLogDAO;
import com.autoheal.dao.DomainDAO;
import com.autoheal.model.Domain;
import com.autoheal.model.User;
import com.autoheal.util.JSONUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.UUID;

@WebServlet(urlPatterns = {"/domains/add", "/domains/delete"})
public class DomainServlet extends HttpServlet {

    private final DomainDAO domainDAO = new DomainDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            JSONUtil.sendJsonResponse(resp, 401, false, "Unauthorized session.", null);
            return;
        }

        User user = (User) session.getAttribute("user");
        String path = req.getServletPath();

        if ("/domains/add".equals(path)) {
            handleAddDomain(req, resp, user);
        } else if ("/domains/delete".equals(path)) {
            handleDeleteDomain(req, resp, user);
        } else {
            JSONUtil.sendJsonResponse(resp, 404, false, "Unknown endpoint.", null);
        }
    }

    private void handleAddDomain(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String domainName = req.getParameter("domainName");

        if (domainName == null || domainName.trim().isEmpty()) {
            JSONUtil.sendJsonResponse(resp, 400, false, "Domain name is required.", null);
            return;
        }

        domainName = domainName.trim().toLowerCase();

        // Basic domain format validation regex
        if (!domainName.matches("^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,}$")) {
            JSONUtil.sendJsonResponse(resp, 400, false, "Invalid domain format (e.g. api.example.com)", null);
            return;
        }

        try {
            if (domainDAO.isDomainExists(user.getOrganizationId(), domainName)) {
                JSONUtil.sendJsonResponse(resp, 400, false, "Domain '" + domainName + "' is already registered in your organization.", null);
                return;
            }

            // Auto-generate secure UUID API Key
            String apiKey = "ahl_live_" + UUID.randomUUID().toString().replace("-", "");

            String githubRepo = req.getParameter("githubRepo");
            String githubToken = req.getParameter("githubToken");

            Domain domain = new Domain();
            domain.setOrganizationId(user.getOrganizationId());
            domain.setDomainName(domainName);
            domain.setApiKey(apiKey);
            domain.setGithubRepo(githubRepo != null && !githubRepo.trim().isEmpty() ? githubRepo.trim() : null);
            domain.setGithubToken(githubToken != null && !githubToken.trim().isEmpty() ? githubToken.trim() : null);

            Long domainId = domainDAO.createDomain(domain);
            domain.setId(domainId);

            auditLogDAO.logAction(user.getOrganizationId(), user.getId(), "DOMAIN_REGISTERED", "Domain '" + domainName + "' registered with new API key");

            // Create default Auto-Healing rules for the new domain
            try {
                com.autoheal.dao.AutoHealingRuleDAO ruleDAO = new com.autoheal.dao.AutoHealingRuleDAO();
                
                // 1. Freeze Error
                com.autoheal.model.AutoHealingRule rule1 = new com.autoheal.model.AutoHealingRule();
                rule1.setDomainId(domainId);
                rule1.setErrorPattern("freeze");
                rule1.setActionType("RESTART_SERVICE");
                rule1.setTargetScript("npm restart");
                rule1.setActive(true);
                ruleDAO.createRule(rule1);

                // 2. CPU Lag Error
                com.autoheal.model.AutoHealingRule rule2 = new com.autoheal.model.AutoHealingRule();
                rule2.setDomainId(domainId);
                rule2.setErrorPattern("cpu lag");
                rule2.setActionType("RESTART_SERVICE");
                rule2.setTargetScript("pm2 restart app");
                rule2.setActive(true);
                ruleDAO.createRule(rule2);

                // 3. Memory Leak Error
                com.autoheal.model.AutoHealingRule rule3 = new com.autoheal.model.AutoHealingRule();
                rule3.setDomainId(domainId);
                rule3.setErrorPattern("memory leak");
                rule3.setActionType("CLEAR_CACHE");
                rule3.setTargetScript("echo \"Clearing cache & freeing memory\"");
                rule3.setActive(true);
                ruleDAO.createRule(rule3);

                // 4. Sync DB Error
                com.autoheal.model.AutoHealingRule rule4 = new com.autoheal.model.AutoHealingRule();
                rule4.setDomainId(domainId);
                rule4.setErrorPattern("CRITICAL: Synchronous database connection failed!");
                rule4.setActionType("RESET_CONNECTION");
                rule4.setTargetScript("echo \"Resetting DB Connections\"");
                rule4.setActive(true);
                ruleDAO.createRule(rule4);

                // 5. Async Gateway Error
                com.autoheal.model.AutoHealingRule rule5 = new com.autoheal.model.AutoHealingRule();
                rule5.setDomainId(domainId);
                rule5.setErrorPattern("FATAL: Unhandled Promise Rejection in payment gateway");
                rule5.setActionType("RESTART_SERVICE");
                rule5.setTargetScript("npm restart");
                rule5.setActive(true);
                ruleDAO.createRule(rule5);

            } catch (Exception e) {
                // Log but don't fail domain creation if default rules fail
                e.printStackTrace();
            }

            JSONUtil.sendJsonResponse(resp, 200, true, "Domain '" + domainName + "' registered successfully!", domain);

        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Database error adding domain: " + e.getMessage(), null);
        }
    }

    private void handleDeleteDomain(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String domainIdStr = req.getParameter("domainId");

        if (domainIdStr == null || domainIdStr.trim().isEmpty()) {
            JSONUtil.sendJsonResponse(resp, 400, false, "Domain ID is required.", null);
            return;
        }

        try {
            Long domainId = Long.parseLong(domainIdStr.trim());
            boolean deleted = domainDAO.deleteDomain(domainId, user.getOrganizationId());

            if (deleted) {
                auditLogDAO.logAction(user.getOrganizationId(), user.getId(), "DOMAIN_DELETED", "Domain ID #" + domainId + " removed");
                JSONUtil.sendJsonResponse(resp, 200, true, "Domain removed successfully.", null);
            } else {
                JSONUtil.sendJsonResponse(resp, 404, false, "Domain not found or unauthorized.", null);
            }

        } catch (NumberFormatException e) {
            JSONUtil.sendJsonResponse(resp, 400, false, "Invalid domain ID format.", null);
        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Database error deleting domain: " + e.getMessage(), null);
        }
    }
}

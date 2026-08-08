package com.autoheal.controller;

import com.autoheal.dao.AuditLogDAO;
import com.autoheal.dao.AutoHealingRuleDAO;
import com.autoheal.dao.DomainDAO;
import com.autoheal.model.AutoHealingRule;
import com.autoheal.model.Domain;
import com.autoheal.model.User;
import com.autoheal.util.CommandSanitizer;
import com.autoheal.util.JSONUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/rules", "/rules/add", "/rules/toggle", "/rules/delete"})
public class AutoHealingRuleServlet extends HttpServlet {

    private final AutoHealingRuleDAO ruleDAO = new AutoHealingRuleDAO();
    private final DomainDAO domainDAO = new DomainDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            List<AutoHealingRule> rules = ruleDAO.findByOrganizationId(user.getOrganizationId());
            List<Domain> domains = domainDAO.findByOrganizationId(user.getOrganizationId());

            req.setAttribute("rules", rules);
            req.setAttribute("domains", domains);
            req.getRequestDispatcher("/rules.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error fetching auto-healing rules: " + e.getMessage());
            req.getRequestDispatcher("/rules.jsp").forward(req, resp);
        }
    }

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

        switch (path) {
            case "/rules/add":
                handleAddRule(req, resp, user);
                break;
            case "/rules/toggle":
                handleToggleRule(req, resp, user);
                break;
            case "/rules/delete":
                handleDeleteRule(req, resp, user);
                break;
            default:
                JSONUtil.sendJsonResponse(resp, 404, false, "Endpoint not found.", null);
                break;
        }
    }

    private void handleAddRule(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String domainIdStr = req.getParameter("domainId");
        String errorPattern = req.getParameter("errorPattern");
        String actionType = req.getParameter("actionType");
        String targetScript = req.getParameter("targetScript");

        if (domainIdStr == null || errorPattern == null || actionType == null || targetScript == null ||
            domainIdStr.trim().isEmpty() || errorPattern.trim().isEmpty() || 
            actionType.trim().isEmpty() || targetScript.trim().isEmpty()) {
            JSONUtil.sendJsonResponse(resp, 400, false, "All fields (Domain, Error Pattern, Action Type, Target Script) are required.", null);
            return;
        }

        try {
            Long domainId = Long.parseLong(domainIdStr.trim());
            
            // Security Command Sanitizer check
            String sanitizedScript;
            try {
                sanitizedScript = CommandSanitizer.sanitizeAndValidate(targetScript.trim());
            } catch (SecurityException se) {
                JSONUtil.sendJsonResponse(resp, 400, false, se.getMessage(), null);
                return;
            }

            AutoHealingRule rule = new AutoHealingRule();
            rule.setDomainId(domainId);
            rule.setErrorPattern(errorPattern.trim());
            rule.setActionType(actionType.trim().toUpperCase());
            rule.setTargetScript(sanitizedScript);
            rule.setActive(true);

            Long ruleId = ruleDAO.createRule(rule);
            rule.setId(ruleId);

            auditLogDAO.logAction(user.getOrganizationId(), user.getId(), "RULE_CREATED", "Auto-healing rule created for pattern '" + errorPattern.trim() + "'");

            JSONUtil.sendJsonResponse(resp, 200, true, "Auto-healing rule created successfully!", rule);

        } catch (NumberFormatException e) {
            JSONUtil.sendJsonResponse(resp, 400, false, "Invalid domain ID.", null);
        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Error adding auto-healing rule: " + e.getMessage(), null);
        }
    }

    private void handleToggleRule(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String ruleIdStr = req.getParameter("ruleId");
        String isActiveStr = req.getParameter("isActive");

        if (ruleIdStr == null || isActiveStr == null) {
            JSONUtil.sendJsonResponse(resp, 400, false, "ruleId and isActive status required.", null);
            return;
        }

        try {
            Long ruleId = Long.parseLong(ruleIdStr.trim());
            boolean isActive = Boolean.parseBoolean(isActiveStr.trim());

            boolean updated = ruleDAO.toggleRuleActive(ruleId, user.getOrganizationId(), isActive);
            if (updated) {
                auditLogDAO.logAction(user.getOrganizationId(), user.getId(), "RULE_TOGGLED", "Rule ID #" + ruleId + " status set to " + (isActive ? "ACTIVE" : "INACTIVE"));
                JSONUtil.sendJsonResponse(resp, 200, true, "Rule status updated to " + (isActive ? "Active" : "Inactive"), null);
            } else {
                JSONUtil.sendJsonResponse(resp, 404, false, "Rule not found or unauthorized.", null);
            }

        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Error toggling rule: " + e.getMessage(), null);
        }
    }

    private void handleDeleteRule(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String ruleIdStr = req.getParameter("ruleId");
        if (ruleIdStr == null) {
            JSONUtil.sendJsonResponse(resp, 400, false, "ruleId parameter required.", null);
            return;
        }

        try {
            Long ruleId = Long.parseLong(ruleIdStr.trim());
            boolean deleted = ruleDAO.deleteRule(ruleId, user.getOrganizationId());
            if (deleted) {
                auditLogDAO.logAction(user.getOrganizationId(), user.getId(), "RULE_DELETED", "Auto-healing rule ID #" + ruleId + " deleted");
                JSONUtil.sendJsonResponse(resp, 200, true, "Rule deleted successfully.", null);
            } else {
                JSONUtil.sendJsonResponse(resp, 404, false, "Rule not found or unauthorized.", null);
            }

        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Error deleting rule: " + e.getMessage(), null);
        }
    }
}

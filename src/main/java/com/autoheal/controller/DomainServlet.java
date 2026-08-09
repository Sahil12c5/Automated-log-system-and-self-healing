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

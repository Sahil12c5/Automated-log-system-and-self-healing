package com.autoheal.controller;

import com.autoheal.dao.DomainDAO;
import com.autoheal.dao.LogDAO;
import com.autoheal.model.Domain;
import com.autoheal.model.LogEntry;
import com.autoheal.model.User;
import com.autoheal.util.JSONUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/logs", "/api/v1/logs"})
public class LogsViewServlet extends HttpServlet {

    private final LogDAO logDAO = new LogDAO();
    private final DomainDAO domainDAO = new DomainDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            String path = req.getServletPath();
            if ("/api/v1/logs".equals(path)) {
                JSONUtil.sendJsonResponse(resp, 401, false, "Unauthorized session.", null);
            } else {
                resp.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        User user = (User) session.getAttribute("user");
        String path = req.getServletPath();

        if ("/api/v1/logs".equals(path)) {
            handleApiLogsQuery(req, resp, user);
        } else {
            handleLogsPageRender(req, resp, user);
        }
    }

    private void handleLogsPageRender(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        try {
            List<Domain> domains = domainDAO.findByOrganizationId(user.getOrganizationId());
            List<LogEntry> initialLogs = logDAO.findByOrganization(user.getOrganizationId(), null, null, null, null, 100);

            req.setAttribute("domains", domains);
            req.setAttribute("logs", initialLogs);
            req.getRequestDispatcher("/logs.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error loading log console: " + e.getMessage());
            req.getRequestDispatcher("/logs.jsp").forward(req, resp);
        }
    }

    private void handleApiLogsQuery(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String domainIdStr = req.getParameter("domainId");
        String logLevel = req.getParameter("logLevel");
        String status = req.getParameter("status");
        String searchQuery = req.getParameter("q");
        String limitStr = req.getParameter("limit");

        Long domainId = null;
        if (domainIdStr != null && !domainIdStr.trim().isEmpty() && !"ALL".equalsIgnoreCase(domainIdStr)) {
            try {
                domainId = Long.parseLong(domainIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        int limit = 100;
        if (limitStr != null && !limitStr.trim().isEmpty()) {
            try {
                limit = Integer.parseInt(limitStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        try {
            List<LogEntry> logs = logDAO.findByOrganization(user.getOrganizationId(), domainId, logLevel, status, searchQuery, limit);
            JSONUtil.sendJsonResponse(resp, 200, true, "Logs retrieved.", logs);
        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Error fetching logs: " + e.getMessage(), null);
        }
    }
}

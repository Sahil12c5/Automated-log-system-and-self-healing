package com.autoheal.controller;

import com.autoheal.dao.AuditLogDAO;
import com.autoheal.dao.DomainDAO;
import com.autoheal.dao.LogDAO;
import com.autoheal.dao.UserDAO;
import com.autoheal.model.AuditLog;
import com.autoheal.model.Domain;
import com.autoheal.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private final DomainDAO domainDAO = new DomainDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();
    private final LogDAO logDAO = new LogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        Long orgId = user.getOrganizationId();

        try {
            List<Domain> domains = domainDAO.findByOrganizationId(orgId);
            int totalDomains = domains.size();
            int activeApiKeys = totalDomains; // Each registered domain has an active API Key
            int totalLogs = logDAO.countTotalLogsByOrganization(orgId);
            int autoHealedLogs = logDAO.countAutoHealedLogsByOrganization(orgId);

            List<AuditLog> auditLogs = auditLogDAO.findRecentByOrganizationId(orgId, 10);
            List<User> orgUsers = userDAO.findByOrganizationId(orgId);

            req.setAttribute("domains", domains);
            req.setAttribute("totalDomains", totalDomains);
            req.setAttribute("activeApiKeys", activeApiKeys);
            req.setAttribute("totalLogs", totalLogs);
            req.setAttribute("autoHealedLogs", autoHealedLogs);
            req.setAttribute("accountStatus", "ACTIVE");
            req.setAttribute("auditLogs", auditLogs);
            req.setAttribute("orgUsers", orgUsers);

            req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error loading dashboard metrics: " + e.getMessage());
            req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
        }
    }
}

package com.autoheal.controller;

import com.autoheal.dao.AuditLogDAO;
import com.autoheal.dao.UserDAO;
import com.autoheal.model.AuditLog;
import com.autoheal.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/audit"})
public class AuditLogServlet extends HttpServlet {

    private final AuditLogDAO auditDAO = new AuditLogDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");

        try {
            // Fetch top 500 audit logs for the organization
            List<AuditLog> auditLogs = auditDAO.findRecentByOrganizationId(currentUser.getOrganizationId(), 500);
            
            // Map User IDs to User Names for display
            Map<Long, String> userNames = new HashMap<>();
            List<User> orgUsers = userDAO.findByOrganizationId(currentUser.getOrganizationId());
            for(User u : orgUsers) {
                userNames.put(u.getId(), u.getFullName());
            }

            req.setAttribute("auditLogs", auditLogs);
            req.setAttribute("userNames", userNames);
            req.getRequestDispatcher("/audit.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error loading audit trail: " + e.getMessage());
            req.getRequestDispatcher("/audit.jsp").forward(req, resp);
        }
    }
}

package com.autoheal.controller;

import com.autoheal.dao.DomainDAO;
import com.autoheal.dao.UserDAO;
import com.autoheal.dao.UserDomainScopeDAO;
import com.autoheal.dao.AuditLogDAO;
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
import java.util.List;

@WebServlet(urlPatterns = {"/team", "/api/v1/team/member", "/api/v1/team/member/delete"})
public class TeamManagementServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final DomainDAO domainDAO = new DomainDAO();
    private final UserDomainScopeDAO scopeDAO = new UserDomainScopeDAO();
    private final AuditLogDAO auditDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");

        try {
            List<User> teamMembers = userDAO.findByOrganizationId(currentUser.getOrganizationId());
            List<Domain> domains = domainDAO.findByOrganizationId(currentUser.getOrganizationId());

            // Get domain scopes for each user (for UI rendering simplicity we could do this via AJAX or map it, but let's just pass raw lists)
            // For a robust app, we'd wrap this in a DTO, but for Phase 4 MVP we'll inject it.
            req.setAttribute("teamMembers", teamMembers);
            req.setAttribute("domains", domains);
            req.getRequestDispatcher("/team.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load team data: " + e.getMessage());
            req.getRequestDispatcher("/team.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");
        String path = req.getRequestURI().substring(req.getContextPath().length());

        try {
            if ("/api/v1/team/member/delete".equals(path)) {
                Long targetUserId = Long.parseLong(req.getParameter("userId"));
                if (targetUserId.equals(currentUser.getId())) {
                    JSONUtil.sendJsonResponse(resp, 400, false, "You cannot delete yourself.", null);
                    return;
                }
                userDAO.deleteUser(targetUserId);
                auditDAO.logAction(currentUser.getOrganizationId(), currentUser.getId(), "USER_DELETED", "Deleted user ID: " + targetUserId);
                JSONUtil.sendJsonResponse(resp, 200, true, "User removed successfully.", null);
                return;
            }

            // Otherwise handle Create/Update
            String email = req.getParameter("email");
            String fullName = req.getParameter("fullName");
            String role = req.getParameter("role");
            String[] domainIds = req.getParameterValues("domainIds[]");
            String userIdParam = req.getParameter("userId"); // if present, it's an update

            if (userIdParam != null && !userIdParam.isEmpty()) {
                // UPDATE
                Long targetUserId = Long.parseLong(userIdParam);
                userDAO.updateRole(targetUserId, role);
                
                scopeDAO.clearScopesForUser(targetUserId);
                if (domainIds != null) {
                    for (String dId : domainIds) {
                        scopeDAO.addScope(targetUserId, Long.parseLong(dId));
                    }
                }
                auditDAO.logAction(currentUser.getOrganizationId(), currentUser.getId(), "USER_UPDATED", "Updated role and scopes for user ID: " + targetUserId);
                JSONUtil.sendJsonResponse(resp, 200, true, "User updated successfully.", null);

            } else {
                // CREATE (Invite)
                if (userDAO.findByEmail(email) != null) {
                    JSONUtil.sendJsonResponse(resp, 400, false, "Email already exists.", null);
                    return;
                }

                User newUser = new User();
                newUser.setOrganizationId(currentUser.getOrganizationId());
                newUser.setFullName(fullName);
                newUser.setEmail(email);
                newUser.setRole(role);
                // Default password for new invited users (for testing)
                // Password@123 hashed
                newUser.setPasswordHash("$2a$10$w8T0O9dO9c2Z7x9/L4v40uYwJg4jF6Xp1kK1wL.A7D9kQ0P.8q4C2"); 
                
                Long newUserId = userDAO.createUser(newUser);
                if (newUserId != null && domainIds != null) {
                    for (String dId : domainIds) {
                        scopeDAO.addScope(newUserId, Long.parseLong(dId));
                    }
                }
                auditDAO.logAction(currentUser.getOrganizationId(), currentUser.getId(), "USER_INVITED", "Invited new user: " + email);
                JSONUtil.sendJsonResponse(resp, 200, true, "User invited successfully.", null);
            }
        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Server error: " + e.getMessage(), null);
        }
    }
}

package com.autoheal.controller;

import com.autoheal.dao.AuditLogDAO;
import com.autoheal.dao.DomainDAO;
import com.autoheal.dao.OrganizationDAO;
import com.autoheal.dao.UserDAO;
import com.autoheal.model.Domain;
import com.autoheal.model.User;
import com.autoheal.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    private final OrganizationDAO organizationDAO = new OrganizationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();
    private final DomainDAO domainDAO = new DomainDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/signup.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String orgName = req.getParameter("orgName");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        // Input Validation
        if (orgName == null || orgName.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("/signup.jsp").forward(req, resp);
            return;
        }

        try {
            // Check if user email or organization already exists
            if (userDAO.findByEmail(email.trim()) != null) {
                req.setAttribute("error", "An account with this email already exists.");
                req.getRequestDispatcher("/signup.jsp").forward(req, resp);
                return;
            }

            if (organizationDAO.findByName(orgName.trim()) != null) {
                req.setAttribute("error", "Organization name is already registered. Please choose another.");
                req.getRequestDispatcher("/signup.jsp").forward(req, resp);
                return;
            }

            // Create Organization
            Long orgId = organizationDAO.createOrganization(orgName.trim());
            if (orgId == null) {
                req.setAttribute("error", "Failed to create organization. Please try again.");
                req.getRequestDispatcher("/signup.jsp").forward(req, resp);
                return;
            }

            // Create Owner User
            String passwordHash = PasswordUtil.hashPassword(password);
            User owner = new User();
            owner.setOrganizationId(orgId);
            owner.setFullName(fullName.trim());
            owner.setEmail(email.trim().toLowerCase());
            owner.setPasswordHash(passwordHash);
            owner.setRole("OWNER");

            Long userId = userDAO.createUser(owner);
            owner.setId(userId);

            // Audit log creation
            auditLogDAO.logAction(orgId, userId, "ORGANIZATION_CREATED", "Organization '" + orgName + "' and Owner account created");

            // Create default Domain
            Domain defaultDomain = new Domain();
            defaultDomain.setOrganizationId(orgId);
            defaultDomain.setDomainName("default.internal");
            defaultDomain.setApiKey("ahl_live_" + UUID.randomUUID().toString().replace("-", ""));
            Long domainId = domainDAO.createDomain(defaultDomain);

            if (domainId != null) {
                auditLogDAO.logAction(orgId, userId, "DOMAIN_REGISTERED", "Default domain 'default.internal' added with API Key");
            }

            // Start Session
            HttpSession session = req.getSession(true);
            session.setAttribute("user", owner);
            session.setAttribute("orgName", orgName.trim());

            resp.sendRedirect(req.getContextPath() + "/dashboard?welcome=true");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "System error during registration: " + e.getMessage());
            req.getRequestDispatcher("/signup.jsp").forward(req, resp);
        }
    }
}

package com.autoheal.controller;

import com.autoheal.dao.AuditLogDAO;
import com.autoheal.dao.OrganizationDAO;
import com.autoheal.dao.UserDAO;
import com.autoheal.model.Organization;
import com.autoheal.model.User;
import com.autoheal.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final OrganizationDAO organizationDAO = new OrganizationDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String errorParam = req.getParameter("error");
        if ("session_expired".equals(errorParam)) {
            req.setAttribute("error", "Your session has expired. Please log in again.");
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String authType = req.getParameter("authType"); // "password" or "otp"
        String email = req.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Email address is required.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        email = email.trim().toLowerCase();

        try {
            User user = userDAO.findByEmail(email);

            if ("password".equals(authType)) {
                String password = req.getParameter("password");
                if (password == null || password.isEmpty()) {
                    req.setAttribute("error", "Password is required.");
                    req.getRequestDispatcher("/login.jsp").forward(req, resp);
                    return;
                }

                if (user == null || !PasswordUtil.checkPassword(password, user.getPasswordHash())) {
                    req.setAttribute("error", "Invalid email or password.");
                    req.getRequestDispatcher("/login.jsp").forward(req, resp);
                    return;
                }

                // Successful Password Login
                loginUserSession(req, resp, user);

            } else {
                req.setAttribute("error", "Invalid authentication request.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Database authentication error: " + e.getMessage());
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    protected void loginUserSession(HttpServletRequest req, HttpServletResponse resp, User user) throws Exception {
        Organization org = organizationDAO.findById(user.getOrganizationId());
        
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("orgName", org != null ? org.getName() : "Organization");

        auditLogDAO.logAction(user.getOrganizationId(), user.getId(), "USER_LOGIN", "User logged in via password");

        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }
}

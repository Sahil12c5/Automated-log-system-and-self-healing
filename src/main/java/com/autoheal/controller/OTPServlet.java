package com.autoheal.controller;

import com.autoheal.dao.AuditLogDAO;
import com.autoheal.dao.OTPDAO;
import com.autoheal.dao.OrganizationDAO;
import com.autoheal.dao.UserDAO;
import com.autoheal.model.Organization;
import com.autoheal.model.User;
import com.autoheal.util.JSONUtil;
import com.autoheal.util.OTPUtil;
import com.autoheal.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(urlPatterns = {"/api/otp/send", "/api/otp/verify", "/api/otp/reset-password"})
public class OTPServlet extends HttpServlet {

    private final OTPDAO otpDAO = new OTPDAO();
    private final UserDAO userDAO = new UserDAO();
    private final OrganizationDAO organizationDAO = new OrganizationDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();

        switch (path) {
            case "/api/otp/send":
                handleSendOTP(req, resp);
                break;
            case "/api/otp/verify":
                handleVerifyOTP(req, resp);
                break;
            case "/api/otp/reset-password":
                handleResetPassword(req, resp);
                break;
            default:
                JSONUtil.sendJsonResponse(resp, 404, false, "Endpoint not found", null);
                break;
        }
    }

    private void handleSendOTP(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            JSONUtil.sendJsonResponse(resp, 400, false, "Email is required.", null);
            return;
        }

        email = email.trim().toLowerCase();

        try {
            User user = userDAO.findByEmail(email);
            if (user == null) {
                JSONUtil.sendJsonResponse(resp, 404, false, "No registered account found with email: " + email, null);
                return;
            }
            
            if ("OWNER".equals(user.getRole())) {
                JSONUtil.sendJsonResponse(resp, 403, false, "Owners must log in via the Owner Password tab.", null);
                return;
            }

            String otpCode = OTPUtil.generate4DigitOTP();
            otpDAO.saveOTP(email, otpCode, 10); // Expires in 10 minutes

            // Dispatch REAL email via SMTP
            com.autoheal.service.EmailService.sendOTPEmail(email, otpCode);

            Map<String, Object> data = new HashMap<>();
            data.put("email", email);

            JSONUtil.sendJsonResponse(resp, 200, true, "OTP code generated and sent successfully to " + email, data);

        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Server error: " + e.getMessage(), null);
        }
    }

    private void handleVerifyOTP(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = req.getParameter("email");
        String otpCode = req.getParameter("otpCode");

        if (email == null || email.trim().isEmpty() || otpCode == null || otpCode.trim().isEmpty()) {
            JSONUtil.sendJsonResponse(resp, 400, false, "Email and OTP code are required.", null);
            return;
        }

        email = email.trim().toLowerCase();
        otpCode = otpCode.trim();

        try {
            boolean isValid = otpDAO.verifyOTP(email, otpCode);
            if (!isValid) {
                JSONUtil.sendJsonResponse(resp, 400, false, "Invalid or expired OTP code.", null);
                return;
            }

            User user = userDAO.findByEmail(email);
            if (user != null) {
                if ("OWNER".equals(user.getRole())) {
                    JSONUtil.sendJsonResponse(resp, 403, false, "Owners must log in via the Owner Password tab.", null);
                    return;
                }
                // Passwordless login session creation
                Organization org = organizationDAO.findById(user.getOrganizationId());
                HttpSession session = req.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("orgName", org != null ? org.getName() : "Organization");

                auditLogDAO.logAction(user.getOrganizationId(), user.getId(), "USER_LOGIN_OTP", "Employee logged in via passwordless OTP");

                Map<String, Object> data = new HashMap<>();
                data.put("redirect", req.getContextPath() + "/dashboard");

                JSONUtil.sendJsonResponse(resp, 200, true, "OTP verified successfully. Authenticating...", data);
            } else {
                JSONUtil.sendJsonResponse(resp, 404, false, "User account not found.", null);
            }

        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Server error verifying OTP: " + e.getMessage(), null);
        }
    }

    private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = req.getParameter("email");
        String otpCode = req.getParameter("otpCode");
        String newPassword = req.getParameter("newPassword");

        if (email == null || email.trim().isEmpty() ||
            otpCode == null || otpCode.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty()) {
            JSONUtil.sendJsonResponse(resp, 400, false, "Email, OTP code, and new password are required.", null);
            return;
        }

        email = email.trim().toLowerCase();

        try {
            boolean isValid = otpDAO.verifyOTP(email, otpCode.trim());
            if (!isValid) {
                JSONUtil.sendJsonResponse(resp, 400, false, "Invalid or expired OTP code.", null);
                return;
            }

            User user = userDAO.findByEmail(email);
            if (user == null) {
                JSONUtil.sendJsonResponse(resp, 404, false, "User not found.", null);
                return;
            }

            String newHash = PasswordUtil.hashPassword(newPassword);
            userDAO.updatePassword(email, newHash);

            auditLogDAO.logAction(user.getOrganizationId(), user.getId(), "PASSWORD_RESET", "Password updated via OTP verification");

            JSONUtil.sendJsonResponse(resp, 200, true, "Password reset successfully! You can now log in with your new password.", null);

        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Server error resetting password: " + e.getMessage(), null);
        }
    }
}

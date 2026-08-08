package com.autoheal.filter;

import com.autoheal.model.User;
import com.autoheal.util.JSONUtil;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebFilter(urlPatterns = {"/team", "/audit", "/api/v1/logs/approve", "/approvals"})
public class RBACFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            if (req.getRequestURI().startsWith(req.getContextPath() + "/api/")) {
                JSONUtil.sendJsonResponse(resp, 401, false, "Unauthorized.", null);
            } else {
                resp.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        User user = (User) session.getAttribute("user");
        String path = req.getRequestURI().substring(req.getContextPath().length());
        String role = user.getRole();

        // RBAC Logic
        boolean authorized = false;

        if (path.startsWith("/team") || path.startsWith("/audit")) {
            // Only OWNER and MANAGER can access Team Management and Audit Logs
            if ("OWNER".equals(role) || "MANAGER".equals(role)) {
                authorized = true;
            }
        } else if (path.startsWith("/api/v1/logs/approve") || path.startsWith("/approvals")) {
            // OWNER, MANAGER, and SENIOR_DEVELOPER can approve AI actions
            if (Arrays.asList("OWNER", "MANAGER", "SENIOR_DEVELOPER").contains(role)) {
                authorized = true;
            }
        }

        if (authorized) {
            chain.doFilter(request, response);
        } else {
            if (path.startsWith("/api/")) {
                JSONUtil.sendJsonResponse(resp, 403, false, "Forbidden: Insufficient privileges.", null);
            } else {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Forbidden: You do not have permission to access this resource.");
            }
        }
    }

    @Override
    public void destroy() {}
}

package com.autoheal.controller;

import com.autoheal.dao.DomainDAO;
import com.autoheal.dao.LogDAO;
import com.autoheal.model.Domain;
import com.autoheal.model.LogEntry;
import com.autoheal.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {"/diagnostics"})
public class AIDiagnosticsViewServlet extends HttpServlet {

    private final LogDAO logDAO = new LogDAO();
    private final DomainDAO domainDAO = new DomainDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            List<Domain> domains = domainDAO.findByOrganizationId(user.getOrganizationId());
            // Fetch PENDING and AI_DIAGNOSED logs
            List<LogEntry> allLogs = logDAO.findByOrganization(user.getOrganizationId(), null, null, null, null, 200);
            List<LogEntry> diagnosticLogs = allLogs.stream()
                .filter(log -> "PENDING".equals(log.getStatus()) || "AI_DIAGNOSED".equals(log.getStatus()))
                .collect(Collectors.toList());

            req.setAttribute("domains", domains);
            req.setAttribute("logs", diagnosticLogs);
            req.getRequestDispatcher("/diagnostics.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error loading diagnostics console: " + e.getMessage());
            req.getRequestDispatcher("/diagnostics.jsp").forward(req, resp);
        }
    }
}

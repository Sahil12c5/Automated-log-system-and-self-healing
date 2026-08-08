package com.autoheal.controller;

import com.autoheal.guardrail.CommandSanitizer;
import com.autoheal.guardrail.RateLimiter;
import com.autoheal.model.User;
import com.autoheal.util.JSONUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {"/guardrails", "/api/v1/guardrails/settings"})
public class GuardrailSettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getServletPath();
        
        if ("/guardrails".equals(pathInfo)) {
            HttpSession session = req.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                resp.sendRedirect("login");
                return;
            }
            // Pass current settings to JSP
            req.setAttribute("maxExecutions", RateLimiter.maxExecutions);
            req.setAttribute("timeWindowMins", RateLimiter.timeWindowMs / (60 * 1000));
            req.setAttribute("blacklist", CommandSanitizer.getBlacklist());
            
            req.getRequestDispatcher("/guardrails.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            JSONUtil.sendJsonResponse(resp, 401, false, "Unauthorized.", null);
            return;
        }

        String action = req.getParameter("action");

        try {
            if ("UPDATE_LIMITS".equals(action)) {
                int maxExecutions = Integer.parseInt(req.getParameter("maxExecutions"));
                RateLimiter.setMaxExecutions(maxExecutions);
                JSONUtil.sendJsonResponse(resp, 200, true, "Rate limits updated successfully.", null);
            } 
            else if ("ADD_KEYWORD".equals(action)) {
                String keyword = req.getParameter("keyword");
                CommandSanitizer.addKeyword(keyword);
                JSONUtil.sendJsonResponse(resp, 200, true, "Keyword added to blacklist.", null);
            }
            else if ("REMOVE_KEYWORD".equals(action)) {
                String keyword = req.getParameter("keyword");
                CommandSanitizer.removeKeyword(keyword);
                JSONUtil.sendJsonResponse(resp, 200, true, "Keyword removed from blacklist.", null);
            }
            else {
                JSONUtil.sendJsonResponse(resp, 400, false, "Invalid action.", null);
            }
        } catch (Exception e) {
            JSONUtil.sendJsonResponse(resp, 500, false, "Error updating guardrails: " + e.getMessage(), null);
        }
    }
}

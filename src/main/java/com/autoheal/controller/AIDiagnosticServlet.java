package com.autoheal.controller;

import com.autoheal.dao.LogDAO;
import com.autoheal.model.LogEntry;
import com.autoheal.model.User;
import com.autoheal.service.GeminiDiagnosticService;
import com.autoheal.util.JSONUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;

@WebServlet(urlPatterns = {"/api/v1/diagnose"})
public class AIDiagnosticServlet extends HttpServlet {

    private final LogDAO logDAO = new LogDAO();
    private final GeminiDiagnosticService geminiService = new GeminiDiagnosticService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            JSONUtil.sendJsonResponse(resp, 401, false, "Unauthorized session.", null);
            return;
        }

        try {
            BufferedReader reader = req.getReader();
            JsonObject requestBody = gson.fromJson(reader, JsonObject.class);
            if (requestBody == null || !requestBody.has("logId")) {
                JSONUtil.sendJsonResponse(resp, 400, false, "Missing logId.", null);
                return;
            }

            Long logId = requestBody.get("logId").getAsLong();
            LogEntry log = logDAO.findById(logId);
            
            if (log == null) {
                JSONUtil.sendJsonResponse(resp, 404, false, "Log not found.", null);
                return;
            }

            // Call Gemini
            GeminiDiagnosticService.DiagnosticResult result = geminiService.analyzeLog(log);
            
            // Update DB
            boolean updated = logDAO.updateLogDiagnosis(logId, result.rootCause, result.remediationSuggestion, "AI_DIAGNOSED");
            
            if (updated) {
                JsonObject data = new JsonObject();
                data.addProperty("aiRootCause", result.rootCause);
                data.addProperty("aiRemediationSuggestion", result.remediationSuggestion);
                data.addProperty("status", "AI_DIAGNOSED");
                JSONUtil.sendJsonResponse(resp, 200, true, "AI Diagnosis Complete.", data);
            } else {
                JSONUtil.sendJsonResponse(resp, 500, false, "Failed to save AI diagnosis.", null);
            }

        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Error during AI diagnosis: " + e.getMessage(), null);
        }
    }
}

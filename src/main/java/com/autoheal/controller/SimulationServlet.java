package com.autoheal.controller;

import com.autoheal.dao.DomainDAO;
import com.autoheal.model.Domain;
import com.autoheal.model.User;
import com.autoheal.util.JSONUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;

@WebServlet("/api/v1/simulation/run")
public class SimulationServlet extends HttpServlet {

    private final DomainDAO domainDAO = new DomainDAO();
    private final Gson gson = new Gson();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            JSONUtil.sendJsonResponse(resp, 401, false, "Unauthorized.", null);
            return;
        }

        User user = (User) session.getAttribute("user");
        String testCase = req.getParameter("testCase"); // A, B, C

        if (testCase == null || testCase.trim().isEmpty()) {
            JSONUtil.sendJsonResponse(resp, 400, false, "Test case parameter missing.", null);
            return;
        }

        try {
            // Pick a domain to send logs to
            List<Domain> domains = domainDAO.findByOrganizationId(user.getOrganizationId());
            if (domains == null || domains.isEmpty()) {
                JSONUtil.sendJsonResponse(resp, 404, false, "No domains found to simulate against.", null);
                return;
            }
            Domain targetDomain = domains.get(0); // Just use the first domain
            String apiKey = targetDomain.getApiKey();
            String ingestUrl = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath() + "/api/v1/logs/ingest";

            if ("A".equalsIgnoreCase(testCase)) {
                // Case A: Known error (Triggers Phase 2)
                String msg = "Connection pool exhausted: Timeout waiting for idle database connection";
                String trace = "java.sql.SQLException: Connection pool exhausted\\n\\tat com.zaxxer.hikari.pool.HikariPool.getConnection";
                sendSimulatedLog(ingestUrl, apiKey, "ERROR", msg, trace);
                JSONUtil.sendJsonResponse(resp, 200, true, "Simulated Known Error (Phase 2).", null);

            } else if ("B".equalsIgnoreCase(testCase)) {
                // Case B: Unknown error (Triggers Phase 3/4)
                String msg = "NullPointerException in PaymentsGateway processing transaction.";
                String trace = "java.lang.NullPointerException\\n\\tat com.acme.PaymentsGateway.process(PaymentsGateway.java:45)";
                sendSimulatedLog(ingestUrl, apiKey, "CRITICAL", msg, trace);
                JSONUtil.sendJsonResponse(resp, 200, true, "Simulated Unknown Error (Phase 3).", null);

            } else if ("C".equalsIgnoreCase(testCase)) {
                // Case C: Loop threshold breach (Phase 5 Guardrail)
                // We fire 4 known errors sequentially
                String msg = "Connection pool exhausted: Timeout waiting for idle database connection";
                String trace = "java.sql.SQLException: Connection pool exhausted\\n\\tat com.zaxxer.hikari.pool.HikariPool.getConnection";
                
                for (int i = 0; i < 4; i++) {
                    sendSimulatedLog(ingestUrl, apiKey, "ERROR", msg + " [Attempt " + (i+1) + "]", trace);
                    Thread.sleep(100); // Small delay
                }
                JSONUtil.sendJsonResponse(resp, 200, true, "Simulated Loop Lockout (4 rapid errors).", null);

            } else {
                JSONUtil.sendJsonResponse(resp, 400, false, "Invalid test case.", null);
            }

        } catch (Exception e) {
            e.printStackTrace();
            JSONUtil.sendJsonResponse(resp, 500, false, "Simulation failed: " + e.getMessage(), null);
        }
    }

    private void sendSimulatedLog(String url, String apiKey, String level, String message, String stackTrace) throws Exception {
        JsonObject payload = new JsonObject();
        payload.addProperty("logLevel", level);
        payload.addProperty("message", message);
        payload.addProperty("stackTrace", stackTrace);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("X-API-KEY", apiKey)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(gson.toJson(payload)))
                .build();

        httpClient.send(request, HttpResponse.BodyHandlers.ofString());
    }
}

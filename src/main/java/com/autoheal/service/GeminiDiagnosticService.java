package com.autoheal.service;

import com.autoheal.model.LogEntry;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

public class GeminiDiagnosticService {
    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=";
    private static final String API_KEY = "AQ.Ab8RN6KkDYdRl5Ah4TMQW5_wERNxG1o7fGnne-uS6c7YHh5qHA";
    private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder()
            .version(HttpClient.Version.HTTP_2)
            .connectTimeout(Duration.ofSeconds(10))
            .build();
    private static final Gson GSON = new Gson();

    public static class DiagnosticResult {
        public String rootCause;
        public String remediationSuggestion;
    }

    public DiagnosticResult analyzeLog(LogEntry log) throws Exception {
        if (API_KEY == null || API_KEY.trim().isEmpty()) {
            throw new Exception("GEMINI_API_KEY environment variable is not set.");
        }

        String prompt = "You are a Senior Backend Java Architect. Diagnose this error and provide actionable insights.\n" +
                "Format your response as a strictly valid JSON object with exactly two keys: 'root_cause' and 'remediation_suggestion'.\n" +
                "Do NOT use markdown code blocks like ```json around the response, output just the raw JSON object.\n\n" +
                "Error Message: " + log.getMessage() + "\n" +
                "Stack Trace: " + (log.getStackTrace() != null ? log.getStackTrace() : "None provided") + "\n";

        JsonObject textPart = new JsonObject();
        textPart.addProperty("text", prompt);

        JsonArray parts = new JsonArray();
        parts.add(textPart);

        JsonObject content = new JsonObject();
        content.add("parts", parts);

        JsonArray contents = new JsonArray();
        contents.add(content);

        JsonObject requestBody = new JsonObject();
        requestBody.add("contents", contents);

        String jsonBody = GSON.toJson(requestBody);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(GEMINI_API_URL + API_KEY))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Gemini API call failed with HTTP " + response.statusCode() + ": " + response.body());
        }

        return parseResponse(response.body());
    }

    private DiagnosticResult parseResponse(String responseBody) throws Exception {
        JsonObject jsonResponse = GSON.fromJson(responseBody, JsonObject.class);
        
        JsonArray candidates = jsonResponse.getAsJsonArray("candidates");
        if (candidates == null || candidates.size() == 0) {
            throw new Exception("No response candidates returned from Gemini.");
        }
        
        JsonObject content = candidates.get(0).getAsJsonObject().getAsJsonObject("content");
        JsonArray parts = content.getAsJsonArray("parts");
        String aiText = parts.get(0).getAsJsonObject().get("text").getAsString().trim();

        if (aiText.startsWith("```json")) {
            aiText = aiText.substring(7);
        }
        if (aiText.startsWith("```")) {
            aiText = aiText.substring(3);
        }
        if (aiText.endsWith("```")) {
            aiText = aiText.substring(0, aiText.length() - 3);
        }
        
        JsonObject parsedAiText = GSON.fromJson(aiText.trim(), JsonObject.class);
        DiagnosticResult result = new DiagnosticResult();
        result.rootCause = parsedAiText.has("root_cause") ? parsedAiText.get("root_cause").getAsString() : "Unable to determine root cause.";
        result.remediationSuggestion = parsedAiText.has("remediation_suggestion") ? parsedAiText.get("remediation_suggestion").getAsString() : "No remediation suggested.";
        
        return result;
    }
}

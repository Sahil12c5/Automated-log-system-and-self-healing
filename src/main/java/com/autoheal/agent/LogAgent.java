package com.autoheal.agent;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class LogAgent {

    private static String apiKey;
    private static String logFilePath;
    private static String serverUrl = "http://localhost:8080/api/v1/logs/ingest";
    private static long pollInterval = 1000;

    private static final Pattern ERROR_PATTERN = Pattern.compile("(?i)(ERROR|CRITICAL|EXCEPTION|FATAL)");

    public static void main(String[] args) {
        parseArgs(args);

        if (apiKey == null || logFilePath == null) {
            System.err.println("Usage: java -jar log-agent.jar --api-key=\"<KEY>\" --log-file=\"<PATH>\" [--server-url=\"<URL>\"] [--poll-interval=<MS>]");
            System.exit(1);
        }

        System.out.println("Starting Log Agent for file: " + logFilePath);
        System.out.println("Target Server: " + serverUrl);
        System.out.println("Polling Interval: " + pollInterval + "ms");

        startTailing();
    }

    private static void parseArgs(String[] args) {
        for (String arg : args) {
            if (arg.startsWith("--api-key=")) {
                apiKey = arg.substring("--api-key=".length()).replace("\"", "");
            } else if (arg.startsWith("--log-file=")) {
                logFilePath = arg.substring("--log-file=".length()).replace("\"", "");
            } else if (arg.startsWith("--server-url=")) {
                serverUrl = arg.substring("--server-url=".length()).replace("\"", "");
            } else if (arg.startsWith("--poll-interval=")) {
                try {
                    pollInterval = Long.parseLong(arg.substring("--poll-interval=".length()));
                } catch (NumberFormatException e) {
                    System.err.println("Invalid poll-interval. Using default (1000ms).");
                }
            }
        }
    }

    private static void startTailing() {
        File file = new File(logFilePath);
        if (!file.exists()) {
            System.err.println("Log file not found: " + logFilePath + ". Waiting for file to be created...");
        }

        long lastPosition = 0;
        if (file.exists()) {
            lastPosition = file.length();
        }

        while (true) {
            try {
                if (file.exists()) {
                    long fileLength = file.length();

                    if (fileLength < lastPosition) {
                        // File was truncated or rotated
                        System.out.println("Log file truncated/rotated. Resetting position.");
                        lastPosition = 0;
                    } else if (fileLength > lastPosition) {
                        try (RandomAccessFile raf = new RandomAccessFile(file, "r")) {
                            raf.seek(lastPosition);
                            
                            List<String> newLines = new ArrayList<>();
                            String line;
                            while ((line = raf.readLine()) != null) {
                                // readLine() returns ISO-8859-1 strings, convert to UTF-8
                                line = new String(line.getBytes(StandardCharsets.ISO_8859_1), StandardCharsets.UTF_8);
                                newLines.add(line);
                            }
                            lastPosition = raf.getFilePointer();

                            processLines(newLines);
                        }
                    }
                }
                
                Thread.sleep(pollInterval);
            } catch (Exception e) {
                System.err.println("Error tailing file: " + e.getMessage());
                try {
                    Thread.sleep(pollInterval);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        }
    }

    private static void processLines(List<String> lines) {
        StringBuilder currentLogEntry = new StringBuilder();
        boolean isErrorBlock = false;

        for (String line : lines) {
            if (ERROR_PATTERN.matcher(line).find()) {
                if (currentLogEntry.length() > 0 && isErrorBlock) {
                    sendPayload(currentLogEntry.toString());
                    currentLogEntry.setLength(0);
                }
                isErrorBlock = true;
                currentLogEntry.append(line).append("\n");
            } else if (isErrorBlock) {
                // If the line starts with a tab or whitespace, it's likely a stack trace continuation
                if (line.startsWith("\t") || line.startsWith(" ") || line.contains("at ")) {
                    currentLogEntry.append(line).append("\n");
                } else {
                    // New standard line, end of error block
                    sendPayload(currentLogEntry.toString());
                    currentLogEntry.setLength(0);
                    isErrorBlock = false;
                }
            }
        }

        if (currentLogEntry.length() > 0 && isErrorBlock) {
            sendPayload(currentLogEntry.toString());
        }
    }

    private static void sendPayload(String logMessage) {
        System.out.println("Detected error log. Sending to ingestion endpoint...");
        
        try {
            URL url = new URL(serverUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("X-API-KEY", apiKey);
            conn.setDoOutput(true);

            JsonObject payload = new JsonObject();
            payload.addProperty("message", logMessage);
            payload.addProperty("timestamp", System.currentTimeMillis());

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = payload.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            
            if (responseCode >= 200 && responseCode < 300) {
                try (InputStream is = conn.getInputStream()) {
                    String responseBody = new String(is.readAllBytes(), StandardCharsets.UTF_8);
                    processResponse(responseBody);
                }
            } else {
                System.err.println("Failed to send log. Server responded with: " + responseCode);
                try (InputStream is = conn.getErrorStream()) {
                    if (is != null) {
                        String errorBody = new String(is.readAllBytes(), StandardCharsets.UTF_8);
                        System.err.println("Error details: " + errorBody);
                    }
                }
            }
            conn.disconnect();

        } catch (Exception e) {
            System.err.println("Error sending log payload: " + e.getMessage());
        }
    }

    private static void processResponse(String responseBody) {
        try {
            if (responseBody == null || responseBody.trim().isEmpty()) {
                return;
            }

            JsonObject responseJson = JsonParser.parseString(responseBody).getAsJsonObject();
            
            if (responseJson.has("commands")) {
                JsonArray commands = responseJson.getAsJsonArray("commands");
                for (int i = 0; i < commands.size(); i++) {
                    String command = commands.get(i).getAsString();
                    executeCommand(command);
                }
            }
        } catch (Exception e) {
            System.err.println("Error parsing server response: " + e.getMessage());
        }
    }

    private static void executeCommand(String command) {
        System.out.println("Received auto-healing command: " + command);
        
        try {
            boolean isWindows = System.getProperty("os.name").toLowerCase().startsWith("windows");
            ProcessBuilder builder = new ProcessBuilder();
            if (isWindows) {
                builder.command("cmd.exe", "/c", command);
            } else {
                builder.command("sh", "-c", command);
            }

            builder.redirectErrorStream(true);
            Process process = builder.start();

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println("CMD OUTPUT: " + line);
                }
            }

            int exitCode = process.waitFor();
            System.out.println("Command executed with exit code: " + exitCode);

        } catch (Exception e) {
            System.err.println("Error executing command: " + e.getMessage());
        }
    }
}

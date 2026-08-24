package com.autoheal.service;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;

public class EmailService {

    private static Properties mailProps = new Properties();
    private static String fromEmail;
    private static String apiKey;

    static {
        try (InputStream input = EmailService.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (input != null) {
                mailProps.load(input);
            } else {
                System.err.println("Warning: email.properties not found in classpath.");
            }
            
            // Prioritize environment variables (for Render deployment) over properties file
            fromEmail = System.getenv("MAIL_USER");
            if (fromEmail == null || fromEmail.trim().isEmpty()) {
                fromEmail = mailProps.getProperty("mail.user", "autohealtool@gmail.com");
            }
            
            apiKey = System.getenv("BREVO_API_KEY");
            if (apiKey == null || apiKey.trim().isEmpty()) {
                // Fallback to MAIL_PASSWORD if they put the API key there
                apiKey = System.getenv("MAIL_PASSWORD");
            }
            if (apiKey == null || apiKey.trim().isEmpty()) {
                apiKey = mailProps.getProperty("mail.password");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void sendOTPEmailAsync(String toEmail, String otpCode) {
        CompletableFuture.runAsync(() -> {
            try {
                sendOTPEmail(toEmail, otpCode);
            } catch (Exception e) {
                System.err.println("Failed to send async OTP to " + toEmail + ": " + e.getMessage());
                e.printStackTrace();
            }
        });
    }

    public static void sendOTPEmail(String toEmail, String otpCode) throws Exception {
        if (apiKey == null || apiKey.trim().isEmpty() || apiKey.contains("your_16_char_app_password") || apiKey.contains("nfui jzct kowl pued")) {
            throw new Exception("Brevo API key is not configured properly. Please set BREVO_API_KEY environment variable.");
        }

        URL url = new URL("https://api.brevo.com/v3/smtp/email");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("accept", "application/json");
        conn.setRequestProperty("api-key", apiKey);
        conn.setRequestProperty("content-type", "application/json");
        conn.setDoOutput(true);
        conn.setConnectTimeout(10000); // 10 seconds
        conn.setReadTimeout(10000);    // 10 seconds

        // Construct JSON Payload using Gson
        JsonObject payload = new JsonObject();
        
        JsonObject sender = new JsonObject();
        sender.addProperty("name", "AutoHeal Engine");
        sender.addProperty("email", fromEmail);
        payload.add("sender", sender);
        
        JsonArray toArray = new JsonArray();
        JsonObject to = new JsonObject();
        to.addProperty("email", toEmail);
        toArray.add(to);
        payload.add("to", toArray);
        
        payload.addProperty("subject", "Your AutoHeal Verification Code");
        
        String htmlContent = "<h2>AutoHeal Platform</h2>"
                + "<p>Hello,</p>"
                + "<p>Your one-time verification code is: <strong style='font-size:1.5em;'>" + otpCode + "</strong></p>"
                + "<p>This code will expire in 10 minutes.</p>"
                + "<p>If you did not request this, please ignore this email.</p>";
        payload.addProperty("htmlContent", htmlContent);

        String jsonInputString = payload.toString();

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonInputString.getBytes("utf-8");
            os.write(input, 0, input.length);
        }

        int code = conn.getResponseCode();
        if (code >= 200 && code < 300) {
            System.out.println("OTP email sent successfully via Brevo API to " + toEmail);
        } else {
            // Log the error stream from Brevo
            try (InputStream errorStream = conn.getErrorStream()) {
                if (errorStream != null) {
                    String errorResponse = new String(errorStream.readAllBytes(), "utf-8");
                    throw new Exception("Brevo API Error (" + code + "): " + errorResponse);
                }
            }
            throw new Exception("Brevo API Error with response code: " + code);
        }
    }
}

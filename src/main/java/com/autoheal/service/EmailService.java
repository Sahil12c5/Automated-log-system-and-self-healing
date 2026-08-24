package com.autoheal.service;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.InputStream;
import java.util.Properties;

public class EmailService {

    private static Properties mailProps = new Properties();
    private static String fromEmail;
    private static String password;

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
                fromEmail = mailProps.getProperty("mail.user");
            }
            
            password = System.getenv("MAIL_PASSWORD");
            if (password == null || password.trim().isEmpty()) {
                password = mailProps.getProperty("mail.password");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void sendOTPEmail(String toEmail, String otpCode) throws Exception {
        if (fromEmail == null || password == null || fromEmail.contains("your.email@gmail.com")) {
            throw new Exception("SMTP credentials are not configured properly in email.properties.");
        }

        Session session = Session.getInstance(mailProps, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(fromEmail, "AutoHeal Engine"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("Your AutoHeal Verification Code");

        String htmlContent = "<h2>AutoHeal Platform</h2>"
                + "<p>Hello,</p>"
                + "<p>Your one-time verification code is: <strong style='font-size:1.5em;'>" + otpCode + "</strong></p>"
                + "<p>This code will expire in 10 minutes.</p>"
                + "<p>If you did not request this, please ignore this email.</p>";

        message.setContent(htmlContent, "text/html; charset=utf-8");

        Transport.send(message);
    }
}

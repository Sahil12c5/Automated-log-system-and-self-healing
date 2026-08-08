package com.autoheal.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

@WebServlet("/download/agent")
public class AgentDownloadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String filePath = getServletContext().getRealPath("/downloads/log-agent-jar-with-dependencies.jar");
        File downloadFile = new File(filePath);

        if (!downloadFile.exists()) {
            // Check for standard log-agent.jar name if it was renamed
            filePath = getServletContext().getRealPath("/downloads/log-agent.jar");
            downloadFile = new File(filePath);
        }

        if (downloadFile.exists()) {
            try (FileInputStream inStream = new FileInputStream(downloadFile)) {
                String mimeType = getServletContext().getMimeType(filePath);
                if (mimeType == null) {
                    mimeType = "application/java-archive";
                }

                response.setContentType(mimeType);
                response.setContentLength((int) downloadFile.length());

                String headerKey = "Content-Disposition";
                String headerValue = String.format("attachment; filename=\"%s\"", "log-agent.jar");
                response.setHeader(headerKey, headerValue);

                try (OutputStream outStream = response.getOutputStream()) {
                    byte[] buffer = new byte[4096];
                    int bytesRead = -1;
                    while ((bytesRead = inStream.read(buffer)) != -1) {
                        outStream.write(buffer, 0, bytesRead);
                    }
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "The log-agent.jar could not be found. Please contact the administrator.");
        }
    }
}

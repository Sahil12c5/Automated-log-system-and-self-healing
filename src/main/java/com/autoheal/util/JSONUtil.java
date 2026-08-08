package com.autoheal.util;

import com.google.gson.Gson;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

public class JSONUtil {
    private static final Gson GSON = new com.google.gson.GsonBuilder()
            .setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX")
            .create();

    public static void sendJsonResponse(HttpServletResponse response, int statusCode, boolean success, String message, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(statusCode);

        Map<String, Object> jsonMap = new HashMap<>();
        jsonMap.put("success", success);
        jsonMap.put("message", message);
        if (data != null) {
            jsonMap.put("data", data);
        }

        PrintWriter out = response.getWriter();
        out.print(GSON.toJson(jsonMap));
        out.flush();
    }
}

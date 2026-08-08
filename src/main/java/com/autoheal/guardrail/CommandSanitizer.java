package com.autoheal.guardrail;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class CommandSanitizer {
    
    private static final List<String> blacklist = new ArrayList<>(Arrays.asList(
        "rm -rf", "mkfs", "dd ", "shutdown", "format", "reboot", "> /dev/sda"
    ));

    public static boolean isSafe(String script) {
        if (script == null || script.trim().isEmpty()) {
            return true;
        }
        
        String lowerScript = script.toLowerCase();
        for (String badCmd : blacklist) {
            if (lowerScript.contains(badCmd)) {
                return false;
            }
        }
        return true;
    }

    public static List<String> getBlacklist() {
        return new ArrayList<>(blacklist);
    }

    public static void addKeyword(String keyword) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            blacklist.add(keyword.trim().toLowerCase());
        }
    }

    public static void removeKeyword(String keyword) {
        if (keyword != null) {
            blacklist.remove(keyword.trim().toLowerCase());
        }
    }
}

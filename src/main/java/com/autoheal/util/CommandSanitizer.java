package com.autoheal.util;

import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

public class CommandSanitizer {

    private static final List<String> BLACKLISTED_COMMANDS = Arrays.asList(
        "rm", "mkfs", "dd", "shutdown", "reboot", "format", "del", "rd",
        "drop", "truncate", "killall", "pkill", "chmod 777", "chown", "sudo"
    );

    // Chaining operators and redirection patterns that can lead to command injection
    private static final Pattern DANGEROUS_CHAR_PATTERN = Pattern.compile("[;&|><`$]");

    // Allowed script path pattern: alphanumeric, hyphen, underscore, slash, dot
    private static final Pattern SAFE_SCRIPT_PATTERN = Pattern.compile("^[a-zA-Z0-9_./-]+$");

    public static boolean isValidScript(String script) {
        if (script == null || script.trim().isEmpty()) {
            return false;
        }

        String trimmed = script.trim().toLowerCase();

        // 1. Check for dangerous chaining symbols
        if (DANGEROUS_CHAR_PATTERN.matcher(trimmed).find()) {
            return false;
        }

        // 2. Check for blacklisted dangerous commands
        for (String blacklisted : BLACKLISTED_COMMANDS) {
            if (trimmed.equals(blacklisted) || 
                trimmed.startsWith(blacklisted + " ") || 
                trimmed.contains(" " + blacklisted + " ") ||
                trimmed.contains("/" + blacklisted)) {
                return false;
            }
        }

        // 3. Verify against allowed characters regex pattern
        return SAFE_SCRIPT_PATTERN.matcher(script.trim()).matches();
    }

    public static String sanitizeAndValidate(String script) throws SecurityException {
        if (!isValidScript(script)) {
            throw new SecurityException("Command rejected by security guardrail: Target script contains blacklisted operators or dangerous commands.");
        }
        return script.trim();
    }
}

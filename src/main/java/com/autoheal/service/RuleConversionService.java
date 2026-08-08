package com.autoheal.service;

import com.autoheal.dao.AutoHealingRuleDAO;
import com.autoheal.model.AutoHealingRule;
import com.autoheal.model.LogEntry;

import java.sql.SQLException;

public class RuleConversionService {
    private final AutoHealingRuleDAO ruleDAO = new AutoHealingRuleDAO();

    /**
     * Converts a successfully approved LogEntry AI fix into a permanent deterministic rule.
     */
    public boolean convertToPermanentRule(LogEntry log) throws SQLException {
        if (log == null || log.getDomainId() == null || log.getMessage() == null) {
            return false;
        }

        // 1. Extract a reliable matching pattern from the log message.
        // For simplicity, we take the first 50 characters or the full message if shorter.
        String fullMsg = log.getMessage();
        String pattern = fullMsg.length() > 50 ? fullMsg.substring(0, 50) + "%" : fullMsg;
        
        // Ensure we don't accidentally create an overly broad catch-all if it's too short
        if (pattern.length() < 10) {
            pattern = fullMsg; 
        }

        // 2. Identify the action type based on the remediation suggestion.
        // A simple heuristic based on common AI outputs.
        String actionType = "CUSTOM_SCRIPT";
        String suggestion = log.getAiRemediationSuggestion() != null ? log.getAiRemediationSuggestion().toUpperCase() : "";
        
        if (suggestion.contains("RESTART") || suggestion.contains("REBOOT")) {
            actionType = "RESTART_SERVICE";
        } else if (suggestion.contains("CLEAR CACHE") || suggestion.contains("FLUSH")) {
            actionType = "CLEAR_CACHE";
        } else if (suggestion.contains("POOL") || suggestion.contains("CONNECTION")) {
            actionType = "RESET_CONNECTION";
        }

        // 3. Create the permanent rule
        AutoHealingRule newRule = new AutoHealingRule();
        newRule.setDomainId(log.getDomainId());
        newRule.setErrorPattern(pattern);
        newRule.setActionType(actionType);
        
        // For CUSTOM_SCRIPT, we mock the script filename. For source code fixes, this would be a patch file.
        boolean isSourceCodeFix = suggestion.contains("```DIFF") || suggestion.contains("DIFF --GIT");
        if (isSourceCodeFix) {
            newRule.setTargetScript("ai_generated_patch_" + log.getId() + ".diff");
        } else {
            newRule.setTargetScript("ai_generated_fix_" + log.getId() + ".sh");
        }
        
        newRule.setActive(true);

        Long ruleId = ruleDAO.createRule(newRule);
        return ruleId != null;
    }
}

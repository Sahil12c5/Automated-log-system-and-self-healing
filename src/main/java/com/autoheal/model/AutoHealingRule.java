package com.autoheal.model;

import java.sql.Timestamp;

public class AutoHealingRule {
    private Long id;
    private Long domainId;
    private String domainName; // Derived field for UI rendering
    private String errorPattern;
    private String actionType; // 'RESTART_SERVICE', 'CLEAR_CACHE', 'RESET_CONNECTION', 'CUSTOM_SCRIPT'
    private String targetScript;
    private boolean isActive;
    private Timestamp createdAt;

    public AutoHealingRule() {}

    public AutoHealingRule(Long id, Long domainId, String errorPattern, String actionType, String targetScript, boolean isActive, Timestamp createdAt) {
        this.id = id;
        this.domainId = domainId;
        this.errorPattern = errorPattern;
        this.actionType = actionType;
        this.targetScript = targetScript;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getDomainId() {
        return domainId;
    }

    public void setDomainId(Long domainId) {
        this.domainId = domainId;
    }

    public String getDomainName() {
        return domainName;
    }

    public void setDomainName(String domainName) {
        this.domainName = domainName;
    }

    public String getErrorPattern() {
        return errorPattern;
    }

    public void setErrorPattern(String errorPattern) {
        this.errorPattern = errorPattern;
    }

    public String getActionType() {
        return actionType;
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    public String getTargetScript() {
        return targetScript;
    }

    public void setTargetScript(String targetScript) {
        this.targetScript = targetScript;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}

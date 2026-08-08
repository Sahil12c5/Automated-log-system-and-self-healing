package com.autoheal.model;

import java.sql.Timestamp;

public class LogEntry {
    private Long id;
    private Long domainId;
    private String domainName; // Derived field for UI rendering
    private String logLevel; // 'INFO', 'WARN', 'ERROR', 'CRITICAL'
    private String message;
    private String stackTrace;
    private String status; // 'PENDING', 'AUTO_HEALED', 'AI_DIAGNOSED', 'APPROVED', 'REJECTED'
    private String executedAction;
    private String aiRootCause;
    private String aiRemediationSuggestion;
    private Timestamp createdAt;

    public LogEntry() {}

    public LogEntry(Long id, Long domainId, String logLevel, String message, String stackTrace, String status, String executedAction, Timestamp createdAt) {
        this.id = id;
        this.domainId = domainId;
        this.logLevel = logLevel;
        this.message = message;
        this.stackTrace = stackTrace;
        this.status = status;
        this.executedAction = executedAction;
        this.createdAt = createdAt;
    }

    public LogEntry(Long id, Long domainId, String logLevel, String message, String stackTrace, String status, String executedAction, String aiRootCause, String aiRemediationSuggestion, Timestamp createdAt) {
        this.id = id;
        this.domainId = domainId;
        this.logLevel = logLevel;
        this.message = message;
        this.stackTrace = stackTrace;
        this.status = status;
        this.executedAction = executedAction;
        this.aiRootCause = aiRootCause;
        this.aiRemediationSuggestion = aiRemediationSuggestion;
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

    public String getLogLevel() {
        return logLevel;
    }

    public void setLogLevel(String logLevel) {
        this.logLevel = logLevel;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getStackTrace() {
        return stackTrace;
    }

    public void setStackTrace(String stackTrace) {
        this.stackTrace = stackTrace;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getExecutedAction() {
        return executedAction;
    }

    public void setExecutedAction(String executedAction) {
        this.executedAction = executedAction;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getAiRootCause() {
        return aiRootCause;
    }

    public void setAiRootCause(String aiRootCause) {
        this.aiRootCause = aiRootCause;
    }

    public String getAiRemediationSuggestion() {
        return aiRemediationSuggestion;
    }

    public void setAiRemediationSuggestion(String aiRemediationSuggestion) {
        this.aiRemediationSuggestion = aiRemediationSuggestion;
    }
}

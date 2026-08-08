package com.autoheal.model;

import java.sql.Timestamp;

public class Domain {
    private Long id;
    private Long organizationId;
    private String domainName;
    private String apiKey;
    private String githubRepo;
    private String githubToken;
    private Timestamp createdAt;

    public Domain() {}

    public Domain(Long id, Long organizationId, String domainName, String apiKey, String githubRepo, String githubToken, Timestamp createdAt) {
        this.id = id;
        this.organizationId = organizationId;
        this.domainName = domainName;
        this.apiKey = apiKey;
        this.githubRepo = githubRepo;
        this.githubToken = githubToken;
        this.createdAt = createdAt;
    }

    public Domain(Long id, Long organizationId, String domainName, String apiKey, Timestamp createdAt) {
        this.id = id;
        this.organizationId = organizationId;
        this.domainName = domainName;
        this.apiKey = apiKey;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getOrganizationId() {
        return organizationId;
    }

    public void setOrganizationId(Long organizationId) {
        this.organizationId = organizationId;
    }

    public String getDomainName() {
        return domainName;
    }

    public void setDomainName(String domainName) {
        this.domainName = domainName;
    }

    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    public String getGithubRepo() {
        return githubRepo;
    }

    public void setGithubRepo(String githubRepo) {
        this.githubRepo = githubRepo;
    }

    public String getGithubToken() {
        return githubToken;
    }

    public void setGithubToken(String githubToken) {
        this.githubToken = githubToken;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}

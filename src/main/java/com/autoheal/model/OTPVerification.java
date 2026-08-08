package com.autoheal.model;

import java.sql.Timestamp;

public class OTPVerification {
    private Long id;
    private String email;
    private String otpCode;
    private Timestamp expiresAt;
    private boolean isUsed;
    private Timestamp createdAt;

    public OTPVerification() {}

    public OTPVerification(Long id, String email, String otpCode, Timestamp expiresAt, boolean isUsed, Timestamp createdAt) {
        this.id = id;
        this.email = email;
        this.otpCode = otpCode;
        this.expiresAt = expiresAt;
        this.isUsed = isUsed;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getOtpCode() {
        return otpCode;
    }

    public void setOtpCode(String otpCode) {
        this.otpCode = otpCode;
    }

    public Timestamp getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Timestamp expiresAt) {
        this.expiresAt = expiresAt;
    }

    public boolean isUsed() {
        return isUsed;
    }

    public void setUsed(boolean used) {
        isUsed = used;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}

package com.autoheal.dao;

import com.autoheal.model.OTPVerification;
import com.autoheal.util.DBConnection;

import java.sql.*;
import java.util.Calendar;

public class OTPDAO {

    public Long saveOTP(String email, String otpCode, int expiryMinutes) throws SQLException {
        String sql = "INSERT INTO otp_verifications (email, otp_code, expires_at, is_used) VALUES (?, ?, ?, false)";
        
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MINUTE, expiryMinutes);
        Timestamp expiresAt = new Timestamp(cal.getTimeInMillis());

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, email);
            stmt.setString(2, otpCode);
            stmt.setTimestamp(3, expiresAt);

            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

    public boolean verifyOTP(String email, String otpCode) throws SQLException {
        String selectSql = "SELECT id FROM otp_verifications WHERE email = ? AND otp_code = ? AND is_used = false AND expires_at > CURRENT_TIMESTAMP ORDER BY id DESC LIMIT 1";
        Long otpId = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(selectSql)) {
            stmt.setString(1, email);
            stmt.setString(2, otpCode);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    otpId = rs.getLong("id");
                }
            }
        }

        if (otpId != null) {
            String updateSql = "UPDATE otp_verifications SET is_used = true WHERE id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                stmt.setLong(1, otpId);
                stmt.executeUpdate();
            }
            return true;
        }

        return false;
    }
}

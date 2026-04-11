package com.VMS.dao;

import com.VMS.config.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * PasswordResetDAO — handles all DB operations for password reset flow.
 *
 * Requires these two columns on your user table (run in phpMyAdmin):
 *   ALTER TABLE user
 *   ADD COLUMN resetToken VARCHAR(255) NULL,
 *   ADD COLUMN resetTokenExpiry DATETIME NULL;
 */
public class PasswordResetDAO {

    /**
     * Check if an email exists in the user table.
     */
    public boolean emailExists(String email) {
        String sql = "SELECT id FROM user WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Generate a unique reset token, save it with a 30-minute expiry,
     * and return the token string.
     */
    public String createResetToken(String email) {
        String token  = UUID.randomUUID().toString();
        // Expiry = now + 30 minutes
        Timestamp expiry = Timestamp.valueOf(LocalDateTime.now().plusMinutes(30));

        String sql = "UPDATE user SET resetToken = ?, resetTokenExpiry = ? WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setTimestamp(2, expiry);
            ps.setString(3, email);
            int rows = ps.executeUpdate();
            if (rows > 0) return token;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Validate that a token exists and has not expired.
     * Returns the user's email if valid, null otherwise.
     */
    public String validateToken(String token) {
        String sql = "SELECT email, resetTokenExpiry FROM user WHERE resetToken = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Timestamp expiry = rs.getTimestamp("resetTokenExpiry");
                // Check token has not expired
                if (expiry != null && expiry.after(new Timestamp(System.currentTimeMillis()))) {
                    return rs.getString("email");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // Token invalid or expired
    }

    /**
     * Update the user's password (already BCrypt hashed) and
     * clear the reset token and expiry so it can't be reused.
     */
    public boolean updatePassword(String token, String hashedPassword) {
        String sql = "UPDATE user SET password = ?, resetToken = NULL, resetTokenExpiry = NULL " +
                     "WHERE resetToken = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setString(2, token);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
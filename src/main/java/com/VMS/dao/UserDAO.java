package com.VMS.dao;

import com.VMS.model.User;
import com.VMS.config.DBConnection;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;

public class UserDAO {

    // Maximum failed attempts before lockout
    private static final int    MAX_ATTEMPTS   = 5;
    // Lockout duration in minutes
    private static final int    LOCKOUT_MINUTES = 15;

    /**
     * Validate user by email and password.
     * Handles account lockout logic:
     *   - Checks if account is locked
     *   - Increments failedAttempts on wrong password
     *   - Resets failedAttempts on successful login
     *   - Locks account after MAX_ATTEMPTS failures
     *
     * Returns:
     *   User object  → login successful
     *   null         → user not found or password wrong
     *   Throws LoginException with reason → account locked or deactivated
     */
    public User validateUserByEmail(String email, String password) throws LoginException {
        String sql = "SELECT * FROM `user` WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                // ── Check if account is deactivated ──
                if (!rs.getBoolean("isActive")) {
                    throw new LoginException("DEACTIVATED",
                        "Your account has been deactivated. Please contact the admin.");
                }

                // ── Check if account is currently locked ──
                Timestamp lockUntil = rs.getTimestamp("lockUntil");
                if (lockUntil != null && lockUntil.after(new Timestamp(System.currentTimeMillis()))) {
                    long remainingMs      = lockUntil.getTime() - System.currentTimeMillis();
                    long remainingMinutes = (remainingMs / 1000 / 60) + 1;
                    throw new LoginException("LOCKED",
                        "Your account is temporarily locked. Please try again in "
                        + remainingMinutes + " minute(s).");
                }

                // ── Check password ──
                String hashedPassword = rs.getString("password");
                String userId         = rs.getString("id");

                if (BCrypt.checkpw(password, hashedPassword)) {
                    // ── SUCCESS — reset failed attempts ──
                    resetFailedAttempts(userId);

                    User user = new User();
                    user.setId(userId);
                    user.setEmail(rs.getString("email"));
                    user.setUsername(rs.getString("username"));
                    user.setPhone(rs.getString("phone"));
                    user.setRole(rs.getString("role"));
                    user.setIsActive(rs.getBoolean("isActive"));
                    return user;

                } else {
                    // ── WRONG PASSWORD — increment failed attempts ──
                    int currentAttempts = rs.getInt("failedAttempts");
                    int newAttempts     = currentAttempts + 1;

                    if (newAttempts >= MAX_ATTEMPTS) {
                        // Lock the account
                        lockAccount(userId);
                        throw new LoginException("LOCKED",
                            "Too many failed attempts. Your account has been locked for "
                            + LOCKOUT_MINUTES + " minutes.");
                    } else {
                        // Increment counter, warn user
                        incrementFailedAttempts(userId, newAttempts);
                        int remaining = MAX_ATTEMPTS - newAttempts;
                        throw new LoginException("WRONG_PASSWORD",
                            "Invalid email or password. " + remaining
                            + " attempt(s) remaining before your account is locked.");
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // User not found
        return null;
    }

    /**
     * Reset failed attempts and clear lock after successful login
     */
    private void resetFailedAttempts(String userId) {
        String sql = "UPDATE `user` SET failedAttempts = 0, lockUntil = NULL WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Increment failed attempts counter
     */
    private void incrementFailedAttempts(String userId, int newAttempts) {
        String sql = "UPDATE `user` SET failedAttempts = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newAttempts);
            ps.setString(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Lock the account for LOCKOUT_MINUTES minutes
     */
    private void lockAccount(String userId) {
        String sql = "UPDATE `user` SET failedAttempts = ?, lockUntil = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            Timestamp lockUntil = Timestamp.valueOf(
                java.time.LocalDateTime.now().plusMinutes(LOCKOUT_MINUTES));
            ps.setInt(1, MAX_ATTEMPTS);
            ps.setTimestamp(2, lockUntil);
            ps.setString(3, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Register a new user with BCrypt-hashed password
     */
    public boolean registerUser(User user) {
        if (emailExists(user.getEmail())) return false;
        if (usernameExists(user.getUsername())) return false;

        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt(12));
        String sql = "INSERT INTO `user` (id, firstName, lastName, email, username, password, phone, role, isActive) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, generateId());
            ps.setString(2, user.getFirstName());
            ps.setString(3, user.getLastName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getUsername());
            ps.setString(6, hashedPassword);
            ps.setString(7, user.getPhone());
            ps.setString(8, "volunteer");
            ps.setBoolean(9, true);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Check if email already exists
     */
    public boolean emailExists(String email) {
        String sql = "SELECT id FROM `user` WHERE email = ?";
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
     * Check if username already exists
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT id FROM `user` WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get user by ID
     */
    public User getUserById(String id) {
        String sql = "SELECT * FROM `user` WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getString("id"));
                user.setEmail(rs.getString("email"));
                user.setUsername(rs.getString("username"));
                user.setPhone(rs.getString("phone"));
                user.setRole(rs.getString("role"));
                user.setIsActive(rs.getBoolean("isActive"));
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Generate a unique user ID
     */
    private String generateId() {
        return java.util.UUID.randomUUID().toString();
    }

    // ══════════════════════════════════════
    // Inner class — LoginException
    // Carries a reason code and message
    // ══════════════════════════════════════
    public static class LoginException extends Exception {
        private final String reason;

        public LoginException(String reason, String message) {
            super(message);
            this.reason = reason;
        }

        public String getReason() {
            return reason;
        }
    }
}
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
     * Inactive volunteers are treated as "pending admin approval".
     */
    public User validateUserByEmail(String email, String password) throws LoginException {
        String sql = "SELECT * FROM `user` WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                // ── Check if account is inactive ──
                if (!rs.getBoolean("isActive")) {
                    String role = rs.getString("role");
                    if ("volunteer".equals(role)) {
                        throw new LoginException("PENDING",
                            "Your registration is pending admin approval. "
                            + "You will be notified once an admin reviews your account.");
                    }
                    throw new LoginException("DEACTIVATED",
                        "Your account has been deactivated. Please contact the administrator.");
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
                String role           = rs.getString("role");

                if (BCrypt.checkpw(password, hashedPassword)) {
                    // ── SUCCESS — reset failed attempts ──
                    resetFailedAttempts(userId);

                    User user = new User();
                    user.setId(userId);
                    user.setEmail(rs.getString("email"));
                    user.setUsername(rs.getString("username"));
                    user.setFirstName(rs.getString("firstName"));
                    user.setLastName(rs.getString("lastName"));
                    user.setPhone(rs.getString("phone"));
                    user.setRole(role);
                    user.setIsActive(rs.getBoolean("isActive"));
                    return user;

                } else {
                    // ── WRONG PASSWORD — increment failed attempts ──
                    int currentAttempts = rs.getInt("failedAttempts");
                    int newAttempts     = currentAttempts + 1;

                    if (newAttempts >= MAX_ATTEMPTS) {
                        lockAccount(userId);
                        throw new LoginException("LOCKED",
                            "Too many failed attempts. Your account has been locked for "
                            + LOCKOUT_MINUTES + " minutes.");
                    } else {
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

        return null;
    }

    /**
     * Register a new user.
     * Sets isActive = FALSE so the account is pending admin approval.
     * Admin approves via the dashboard (sets isActive = TRUE).
     */
    public boolean registerUser(User user) {
        if (emailExists(user.getEmail()))    return false;
        if (usernameExists(user.getUsername())) return false;

        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt(12));
        String userId = generateId();

        String sql = "INSERT INTO `user` (id, firstName, lastName, email, username, password, phone, role, isActive) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'volunteer', false)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ps.setString(2, user.getFirstName());
            ps.setString(3, user.getLastName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getUsername());
            ps.setString(6, hashedPassword);
            ps.setString(7, user.getPhone());

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
     * Check if phone number already exists
     */
    public boolean phoneExists(String phone) {
        if (phone == null || phone.trim().isEmpty()) return false;
        String sql = "SELECT id FROM `user` WHERE phone = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
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
                user.setFirstName(rs.getString("firstName"));
                user.setLastName(rs.getString("lastName"));
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

    // Private helper methods
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

    private String generateId() {
        return java.util.UUID.randomUUID().toString();
    }

    // ══════════════════════════════════════
    // Inner class — LoginException
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
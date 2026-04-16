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
     * Checks volunteer table for acceptance status before allowing login
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

                if (BCrypt.checkpw(password, hashedPassword)) {
                    // ── SUCCESS — reset failed attempts ──
                    resetFailedAttempts(userId);

                    // ── For volunteers, check if any registration is ACCEPTED ──
                    String role = rs.getString("role");
                    if ("volunteer".equals(role)) {
                        VolunteerDAO volunteerDao = new VolunteerDAO();
                        if (!volunteerDao.hasAcceptedVolunteerStatus(userId)) {
                            throw new LoginException("PENDING_APPROVAL",
                                "Your volunteer registration is pending admin approval. You will receive an email when approved.");
                        }
                    }

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
     * Register a new user with BCrypt-hashed password
     * NEW: Also creates entry in volunteer table with 'pending' status
     * IMPORTANT: This method requires an eventId parameter now
     */
    public boolean registerUser(User user, String eventId) {
        if (emailExists(user.getEmail())) return false;
        if (usernameExists(user.getUsername())) return false;

        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt(12));
        String userId = generateId();
        
        // Start transaction: insert into both user and volunteer tables
        String insertUserSql = "INSERT INTO `user` (id, firstName, lastName, email, username, password, phone, role, isActive) " +
                              "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        String insertVolunteerSql = "INSERT INTO `volunteer` (userId, eventId, status) " +
                                   "VALUES (?, ?, 'pending')";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);  // Start transaction
            
            // Insert into user table
            try (PreparedStatement ps1 = conn.prepareStatement(insertUserSql)) {
                ps1.setString(1, userId);
                ps1.setString(2, user.getFirstName());
                ps1.setString(3, user.getLastName());
                ps1.setString(4, user.getEmail());
                ps1.setString(5, user.getUsername());
                ps1.setString(6, hashedPassword);
                ps1.setString(7, user.getPhone());
                ps1.setString(8, "volunteer");
                ps1.setBoolean(9, true);  // isActive = true (user can exist in system)
                
                int userInserted = ps1.executeUpdate();
                if (userInserted == 0) {
                    conn.rollback();
                    return false;
                }
            }
            
            // Insert into volunteer table (with pending status)
            try (PreparedStatement ps2 = conn.prepareStatement(insertVolunteerSql)) {
                ps2.setString(1, userId);
                ps2.setString(2, eventId);
                
                int volunteerInserted = ps2.executeUpdate();
                if (volunteerInserted == 0) {
                    conn.rollback();
                    return false;
                }
            }
            
            conn.commit();  // Both inserts successful
            return true;
            
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
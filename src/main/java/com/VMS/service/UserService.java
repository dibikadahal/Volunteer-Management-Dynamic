package com.VMS.service;

import com.VMS.model.User;
import com.VMS.config.DBConnection;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;
import java.util.UUID;

public class UserService {

    /**
     * Register a new user with BCrypt-hashed password
     * Matches exact DB columns: id, email, username, password, phone, role, isActive
     */
    public boolean registerUser(User user) throws SQLException {

        // Check for duplicates first
        if (isEmailTaken(user.getEmail())) {
            throw new SQLException("Duplicate entry '" + user.getEmail() + "' for key 'user_email_unique'");
        }
        if (isUsernameTaken(user.getUsername())) {
            throw new SQLException("Duplicate entry '" + user.getUsername() + "' for key 'user_username_unique'");
        }

        // Hash the plain-text password before storing
        String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt(12));

        // Only insert columns that actually exist in your table
        String sql = "INSERT INTO user (id, email, username, password, phone, role, isActive) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, UUID.randomUUID().toString());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getUsername());
            ps.setString(4, hashedPassword);        // Stored as BCrypt hash e.g. $2a$12$...
            ps.setString(5, user.getPhone());
            ps.setString(6, "volunteer");            // Default role
            ps.setBoolean(7, true);                  // isActive default

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Login user — verifies BCrypt hash against stored hash
     */
    public User loginUser(String email, String password) throws SQLException {
        String sql = "SELECT * FROM user WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // Check if account is active
                if (!rs.getBoolean("isActive")) {
                    return null; // Account deactivated
                }

                String hashedPassword = rs.getString("password");

                // BCrypt verification
                if (BCrypt.checkpw(password, hashedPassword)) {
                    User user = new User();
                    user.setId(rs.getString("id"));
                    user.setEmail(rs.getString("email"));
                    user.setUsername(rs.getString("username"));
                    user.setPhone(rs.getString("phone"));
                    user.setRole(rs.getString("role"));
                    user.setIsActive(rs.getBoolean("isActive"));
                    return user;
                }
            }
        }

        return null; // Login failed
    }

    /**
     * Check if email already exists
     */
    public boolean isEmailTaken(String email) throws SQLException {
        String sql = "SELECT id FROM user WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }

    /**
     * Check if username already exists
     */
    public boolean isUsernameTaken(String username) throws SQLException {
        String sql = "SELECT id FROM user WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }
}
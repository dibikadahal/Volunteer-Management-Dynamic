package com.VMS.dao;

import com.VMS.config.DBConnection;
import com.VMS.model.User;
import java.sql.*;

public class ProfileDAO {

    /**
     * Get full user profile by ID
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
                user.setFirstName(rs.getString("firstName") != null ? rs.getString("firstName") : "");
                user.setLastName(rs.getString("lastName") != null ? rs.getString("lastName") : "");
                user.setEmail(rs.getString("email"));
                user.setUsername(rs.getString("username"));
                user.setPhone(rs.getString("phone") != null ? rs.getString("phone") : "");
                user.setBio(rs.getString("bio") != null ? rs.getString("bio") : "");
                user.setImage(rs.getString("image") != null ? rs.getString("image") : "");
                user.setRole(rs.getString("role"));
                user.setIsActive(rs.getBoolean("isActive"));
                user.setCreatedAt(rs.getTimestamp("createdAt"));
                return user;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Update user profile — text fields only
     */
    public boolean updateProfile(String id, String firstName, String lastName,
                                  String email, String username, String phone, String bio) {
        String sql = "UPDATE `user` SET firstName=?, lastName=?, email=?, username=?, phone=?, bio=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, email);
            ps.setString(4, username);
            ps.setString(5, phone);
            ps.setString(6, bio);
            ps.setString(7, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update profile photo path in DB
     */
    public boolean updateProfilePhoto(String id, String imagePath) {
        String sql = "UPDATE `user` SET image=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, imagePath);
            ps.setString(2, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Check if email is taken by another user
     */
    public boolean isEmailTakenByOther(String email, String currentUserId) {
        String sql = "SELECT id FROM `user` WHERE email=? AND id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, currentUserId);
            return ps.executeQuery().next();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Check if username is taken by another user
     */
    public boolean isUsernameTakenByOther(String username, String currentUserId) {
        String sql = "SELECT id FROM `user` WHERE username=? AND id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, currentUserId);
            return ps.executeQuery().next();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
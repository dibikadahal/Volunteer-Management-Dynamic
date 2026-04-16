package com.VMS.dao;

import com.VMS.config.DBConnection;
import java.sql.*;

/**
 * DAO for volunteer table operations
 * Manages volunteer status: pending, accepted, declined
 */
public class VolunteerDAO {

    /**
     * Get volunteer status for a user and event
     * Returns: "pending", "accepted", "declined", or null if not found
     */
    public String getVolunteerStatus(String userId, String eventId) {
        String sql = "SELECT status FROM `volunteer` WHERE userId = ? AND eventId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("status");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Check if volunteer has any ACCEPTED registrations
     * Returns true if user has at least one accepted volunteer status
     */
    public boolean hasAcceptedVolunteerStatus(String userId) {
        String sql = "SELECT COUNT(*) as count FROM `volunteer` WHERE userId = ? AND status = 'accepted'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get all pending volunteer registrations (for admin dashboard)
     * Returns ResultSet with user and event details
     */
    public ResultSet getPendingVolunteers() {
        String sql = "SELECT v.userId, v.eventId, v.joinedAt, v.status, " +
                     "u.firstName, u.lastName, u.email, u.phone, " +
                     "e.title as eventTitle " +
                     "FROM `volunteer` v " +
                     "JOIN `user` u ON v.userId = u.id " +
                     "JOIN `event` e ON v.eventId = e.id " +
                     "WHERE v.status = 'pending' " +
                     "ORDER BY v.joinedAt DESC";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            return stmt.executeQuery(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Update volunteer status (used by admin)
     * status: "accepted" or "declined"
     */
    public boolean updateVolunteerStatus(String userId, String eventId, String status) {
        String sql = "UPDATE `volunteer` SET status = ? WHERE userId = ? AND eventId = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, userId);
            ps.setString(3, eventId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
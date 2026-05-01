package com.VMS.dao;

import com.VMS.config.DBConnection;
import com.VMS.model.VolunteerAssignmentEntry;
import com.VMS.model.VolunteerNotification;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

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
     * Insert a new pending volunteer request. Returns false if already exists.
     */
    public boolean requestVolunteer(String userId, String eventId) {
        if (getVolunteerStatus(userId, eventId) != null) return false;
        String sql = "INSERT INTO `volunteer` (userId, eventId, status, joinedAt) VALUES (?, ?, 'pending', NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, eventId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Return the 5 most recent accepted/declined notifications for a volunteer.
     * Used to show interactive status messages on the dashboard.
     */
    public List<VolunteerNotification> getStatusNotifications(String userId) {
        List<VolunteerNotification> list = new ArrayList<>();
        String sql = "SELECT v.status, v.joinedAt, e.id AS eventId, e.title AS eventTitle " +
                     "FROM `volunteer` v " +
                     "JOIN `event` e ON v.eventId = e.id " +
                     "WHERE v.userId = ? AND v.status IN ('accepted', 'declined') " +
                     "ORDER BY v.joinedAt DESC LIMIT 5";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
            while (rs.next()) {
                VolunteerNotification n = new VolunteerNotification();
                n.setEventId(rs.getString("eventId"));
                n.setEventTitle(rs.getString("eventTitle"));
                n.setStatus(rs.getString("status"));
                Timestamp ts = rs.getTimestamp("joinedAt");
                n.setUpdatedAt(ts != null ? sdf.format(ts) : "");
                list.add(n);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** All pending (awaiting admin decision) event requests for a volunteer. */
    public List<VolunteerAssignmentEntry> getPendingRequestsForVolunteer(String userId) {
        List<VolunteerAssignmentEntry> list = new ArrayList<>();
        String sql =
            "SELECT e.id AS eventId, e.title, e.location, e.startsAt, e.endsAt, " +
            "       e.status AS eventStatus, v.joinedAt " +
            "FROM `volunteer` v JOIN `event` e ON v.eventId = e.id " +
            "WHERE v.userId=? AND v.status='pending' ORDER BY v.joinedAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            SimpleDateFormat dtFmt   = new SimpleDateFormat("MMM dd, yyyy HH:mm");
            SimpleDateFormat dateFmt = new SimpleDateFormat("MMM dd, yyyy");
            Timestamp now = new Timestamp(System.currentTimeMillis());
            while (rs.next()) {
                VolunteerAssignmentEntry e = new VolunteerAssignmentEntry();
                e.setEventId    (nvl(rs.getString("eventId")));
                e.setTitle      (nvl(rs.getString("title")));
                e.setLocation   (nvl(rs.getString("location")));
                e.setEventStatus(nvl(rs.getString("eventStatus")));
                Timestamp startsAt = rs.getTimestamp("startsAt");
                Timestamp endsAt   = rs.getTimestamp("endsAt");
                Timestamp joinedAt = rs.getTimestamp("joinedAt");
                e.setStartsAt(startsAt != null ? dtFmt.format(startsAt)   : "");
                e.setEndsAt  (endsAt   != null ? dtFmt.format(endsAt)     : "");
                e.setJoinedAt(joinedAt != null ? dateFmt.format(joinedAt) : "");
                e.setMarkedAt("");
                e.setAttended(false);
                e.setHasAssignment(false);
                e.setPointsEarned(0);
                e.setPast(endsAt != null && endsAt.before(now));
                list.add(e);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return list;
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

    private static String nvl(String s) { return s != null ? s : ""; }
}
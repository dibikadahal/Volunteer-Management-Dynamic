package com.VMS.dao;

import com.VMS.config.DBConnection;
import com.VMS.model.User;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class AdminDashboardDAO {

    // ── Pending volunteers (isActive=false, role=volunteer) ──
    public List<User> getPendingVolunteers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM `user` WHERE role='volunteer' AND isActive=false ORDER BY createdAt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapUser(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int countPendingVolunteers() {
        return countWhere("role='volunteer' AND isActive=false");
    }

    public int countActiveVolunteers() {
        return countWhere("role='volunteer' AND isActive=true");
    }

    public int countTotalVolunteers() {
        return countWhere("role='volunteer'");
    }

    // ── Recent approved volunteers (for the "Recent Registrations" panel) ──
    public List<User> getRecentApprovedVolunteers(int limit) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM `user` WHERE role='volunteer' AND isActive=true " +
                     "ORDER BY createdAt DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapUser(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Pending event join requests: approved volunteers who requested to join an event
     * but admin hasn't accepted or declined yet. Returns up to 10 most recent.
     * Each map contains: userId, volunteerName, volunteerEmail, eventId, eventTitle,
     *                    eventStartsAt (formatted), location, requestedOn (formatted).
     */
    public List<Map<String, Object>> getPendingEventRequests() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT v.userId, v.eventId, v.joinedAt, " +
            "       u.firstName, u.lastName, u.email, u.username, " +
            "       e.title AS eventTitle, e.startsAt, e.location " +
            "FROM `volunteer` v " +
            "JOIN `user`  u ON v.userId  = u.id " +
            "JOIN `event` e ON v.eventId = e.id " +
            "WHERE v.status = 'pending' AND u.isActive = true " +
            "ORDER BY v.joinedAt DESC LIMIT 10";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            SimpleDateFormat dtFmt   = new SimpleDateFormat("MMM dd, yyyy HH:mm");
            SimpleDateFormat dateFmt = new SimpleDateFormat("MMM dd, yyyy");
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("userId",        rs.getString("userId"));
                row.put("eventId",       rs.getString("eventId"));
                row.put("volunteerName", nvl(rs.getString("firstName")) + " " + nvl(rs.getString("lastName")));
                row.put("email",         nvl(rs.getString("email")));
                row.put("username",      nvl(rs.getString("username")));
                row.put("eventTitle",    nvl(rs.getString("eventTitle")));
                row.put("location",      nvl(rs.getString("location")));
                Timestamp startsAt  = rs.getTimestamp("startsAt");
                Timestamp joinedAt  = rs.getTimestamp("joinedAt");
                row.put("eventStartsAt", startsAt != null ? dtFmt.format(startsAt)   : "—");
                row.put("requestedOn",   joinedAt != null ? dateFmt.format(joinedAt) : "—");
                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int countPendingEventRequests() {
        String sql = "SELECT COUNT(*) FROM `volunteer` v " +
                     "JOIN `user` u ON v.userId = u.id " +
                     "WHERE v.status = 'pending' AND u.isActive = true";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ── Approve: set isActive=true ──
    public boolean approveVolunteer(String id) {
        String sql = "UPDATE `user` SET isActive=true WHERE id=? AND role='volunteer'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Decline: delete the pending user ──
    public boolean declineVolunteer(String id) {
        String sql = "DELETE FROM `user` WHERE id=? AND role='volunteer' AND isActive=false";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    // ── Helpers ──
    private int countWhere(String condition) {
        String sql = "SELECT COUNT(*) FROM `user` WHERE " + condition;
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    private static String nvl(String s) { return s != null ? s : ""; }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getString("id"));
        u.setFirstName(rs.getString("firstName") != null ? rs.getString("firstName") : "");
        u.setLastName(rs.getString("lastName")   != null ? rs.getString("lastName")  : "");
        u.setEmail(rs.getString("email"));
        u.setUsername(rs.getString("username"));
        u.setPhone(rs.getString("phone")         != null ? rs.getString("phone")     : "");
        u.setBio(rs.getString("bio")             != null ? rs.getString("bio")       : "");
        u.setRole(rs.getString("role"));
        u.setIsActive(rs.getBoolean("isActive"));
        u.setCreatedAt(rs.getTimestamp("createdAt"));
        return u;
    }
}

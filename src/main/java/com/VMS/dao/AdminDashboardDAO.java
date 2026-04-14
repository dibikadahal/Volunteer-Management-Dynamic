package com.VMS.dao;

import com.VMS.config.DBConnection;
import com.VMS.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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

package com.VMS.dao;

import com.VMS.config.DBConnection;
import com.VMS.model.User;
import com.VMS.model.VolunteerEventEntry;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class VolunteerManagementDAO {

    private static final Set<String> SORT_COLS = new HashSet<>(Arrays.asList(
        "firstName", "lastName", "email", "createdAt"
    ));

    // ═══════════════════════════════════════════════
    // VOLUNTEER LIST
    // ═══════════════════════════════════════════════

    /**
     * Return all ACTIVE volunteers with their total event registration count.
     * Supports keyword search (name / email / phone) and column sorting.
     */
    public List<User> getAllActiveVolunteers(String search, String sortBy, String sortDir) {
        List<User> list = new ArrayList<>();

        String col = SORT_COLS.contains(sortBy) ? sortBy : "createdAt";
        String dir = "asc".equalsIgnoreCase(sortDir) ? "ASC" : "DESC";
        boolean hasSearch = search != null && !search.trim().isEmpty();

        String sql =
            "SELECT u.*, COALESCE(ec.cnt, 0) AS eventCount " +
            "FROM `user` u " +
            "LEFT JOIN (SELECT userId, COUNT(*) AS cnt FROM `volunteer` GROUP BY userId) ec " +
            "  ON u.id = ec.userId " +
            "WHERE u.role = 'volunteer' AND u.isActive = true " +
            (hasSearch
                ? "AND (u.firstName LIKE ? OR u.lastName LIKE ? OR u.email LIKE ? OR u.phone LIKE ?) "
                : "") +
            "ORDER BY u.`" + col + "` " + dir;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (hasSearch) {
                String like = "%" + search.trim() + "%";
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
                ps.setString(4, like);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapUser(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ═══════════════════════════════════════════════
    // EVENTS PER VOLUNTEER (batch — avoids N+1)
    // ═══════════════════════════════════════════════

    /**
     * Given a list of volunteer user IDs, return a Map from userId → list of their event entries.
     * Uses a single IN query for efficiency.
     */
    public Map<String, List<VolunteerEventEntry>> getVolunteerEventsMap(List<String> userIds) {
        Map<String, List<VolunteerEventEntry>> map = new LinkedHashMap<>();
        if (userIds == null || userIds.isEmpty()) return map;

        // Build IN clause placeholders
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < userIds.size(); i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }

        String sql =
            "SELECT v.userId, e.id AS eventId, e.title, e.location, " +
            "       e.startsAt, e.endsAt, e.status AS eventStatus, " +
            "       v.status AS volunteerStatus, v.joinedAt " +
            "FROM `volunteer` v " +
            "JOIN `event` e ON v.eventId = e.id " +
            "WHERE v.userId IN (" + placeholders + ") " +
            "ORDER BY v.userId, v.joinedAt DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 0; i < userIds.size(); i++) {
                ps.setString(i + 1, userIds.get(i));
            }

            SimpleDateFormat dtFmt  = new SimpleDateFormat("MMM dd, yyyy HH:mm");
            SimpleDateFormat dateFmt = new SimpleDateFormat("MMM dd, yyyy");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String uid = rs.getString("userId");
                map.computeIfAbsent(uid, k -> new ArrayList<>());

                VolunteerEventEntry entry = new VolunteerEventEntry();
                entry.setEventId(rs.getString("eventId"));
                entry.setTitle(rs.getString("title"));
                entry.setLocation(rs.getString("location") != null ? rs.getString("location") : "");
                entry.setEventStatus(rs.getString("eventStatus"));
                entry.setVolunteerStatus(rs.getString("volunteerStatus"));

                Timestamp starts = rs.getTimestamp("startsAt");
                Timestamp ends   = rs.getTimestamp("endsAt");
                Timestamp joined = rs.getTimestamp("joinedAt");

                entry.setStartsAt(starts != null ? dtFmt.format(starts)   : "—");
                entry.setEndsAt  (ends   != null ? dtFmt.format(ends)     : "—");
                entry.setJoinedAt(joined != null ? dateFmt.format(joined) : "—");

                map.get(uid).add(entry);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    // ═══════════════════════════════════════════════
    // STATISTICS
    // ═══════════════════════════════════════════════

    /** Total accepted volunteer-event registrations across all events. */
    public int countTotalRegistrations() {
        String sql = "SELECT COUNT(*) FROM `volunteer` WHERE status = 'accepted'";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ═══════════════════════════════════════════════
    // PRIVATE HELPERS
    // ═══════════════════════════════════════════════

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getString("id"));
        u.setFirstName(rs.getString("firstName") != null ? rs.getString("firstName") : "");
        u.setLastName (rs.getString("lastName")  != null ? rs.getString("lastName")  : "");
        u.setEmail    (rs.getString("email"));
        u.setUsername (rs.getString("username"));
        u.setPhone    (rs.getString("phone")     != null ? rs.getString("phone")     : "");
        u.setBio      (rs.getString("bio")       != null ? rs.getString("bio")       : "");
        u.setRole     (rs.getString("role"));
        u.setIsActive (rs.getBoolean("isActive"));
        u.setCreatedAt(rs.getTimestamp("createdAt"));
        u.setEventCount(rs.getInt("eventCount"));

        try { u.setImage(rs.getString("image")); } catch (SQLException ignored) {}

        return u;
    }
}

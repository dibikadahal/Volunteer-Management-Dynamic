package com.VMS.dao;

import com.VMS.config.DBConnection;
import com.VMS.model.Event;

import java.sql.*;
import java.util.*;

/**
 * EventDAO — full CRUD + statistics for the event table.
 *
 * Requires these extra columns (run once in phpMyAdmin):
 *   ALTER TABLE `event` ADD COLUMN `location` varchar(255) NULL AFTER `maxlimit`;
 *   ALTER TABLE `event` ADD COLUMN `image`    text         NULL AFTER `location`;
 */
public class EventDAO {

    // Whitelist for dynamic ORDER BY — prevents SQL injection
    private static final Set<String> SORT_COLS = new HashSet<>(Arrays.asList(
        "title", "status", "startsAt", "endsAt", "createdAt", "maxlimit"
    ));

    // ── Shared SQL fragment: event + accepted volunteer count ──
    private static final String SELECT_BASE =
        "SELECT e.*, COALESCE(vc.cnt, 0) AS volunteerCount " +
        "FROM `event` e " +
        "LEFT JOIN (SELECT eventId, COUNT(*) AS cnt FROM `volunteer` " +
        "           WHERE status = 'accepted' GROUP BY eventId) vc " +
        "  ON e.id = vc.eventId ";

    // ═══════════════════════════════════════════════
    // READ
    // ═══════════════════════════════════════════════

    /**
     * Return all events. Optionally filter by search string and sort by column.
     *
     * @param search  keyword to match against title / description / location (null = no filter)
     * @param sortBy  column name (whitelist-checked; defaults to createdAt)
     * @param sortDir "asc" or "desc" (defaults to desc)
     */
    public List<Event> getAllEvents(String search, String sortBy, String sortDir) {
        List<Event> events = new ArrayList<>();

        String col = SORT_COLS.contains(sortBy) ? sortBy : "createdAt";
        String dir = "asc".equalsIgnoreCase(sortDir) ? "ASC" : "DESC";

        boolean hasSearch = search != null && !search.trim().isEmpty();
        String sql = SELECT_BASE
            + (hasSearch ? "WHERE e.title LIKE ? OR e.description LIKE ? OR e.location LIKE ? " : "")
            + "ORDER BY e.`" + col + "` " + dir;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (hasSearch) {
                String like = "%" + search.trim() + "%";
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) events.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return events;
    }

    /**
     * Return all events enriched with the requesting volunteer's own status.
     * Used by the volunteer Browse Events page.
     *
     * @param userId  the logged-in volunteer's user ID
     * @param search  optional keyword filter (title / description / location)
     * @param sortBy  column name (whitelist-checked)
     * @param sortDir "asc" or "desc"
     */
    public List<Event> getAllEventsWithStatus(String userId, String search, String sortBy, String sortDir) {
        List<Event> events = new ArrayList<>();

        String col = SORT_COLS.contains(sortBy) ? sortBy : "createdAt";
        String dir = "asc".equalsIgnoreCase(sortDir) ? "ASC" : "DESC";

        boolean hasSearch = search != null && !search.trim().isEmpty();

        String sql =
            "SELECT e.*, COALESCE(vc.cnt, 0) AS volunteerCount, v.status AS myStatus " +
            "FROM `event` e " +
            "LEFT JOIN (SELECT eventId, COUNT(*) AS cnt FROM `volunteer` " +
            "           WHERE status = 'accepted' GROUP BY eventId) vc " +
            "  ON e.id = vc.eventId " +
            "LEFT JOIN `volunteer` v ON e.id = v.eventId AND v.userId = ? " +
            (hasSearch ? "WHERE e.title LIKE ? OR e.description LIKE ? OR e.location LIKE ? " : "") +
            "ORDER BY e.`" + col + "` " + dir;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = 1;
            ps.setString(idx++, userId);
            if (hasSearch) {
                String like = "%" + search.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Event e = mapRow(rs);
                e.setMyStatus(rs.getString("myStatus"));
                events.add(e);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return events;
    }

    /**
     * Get a single event by its primary key.
     */
    public Event getEventById(String id) {
        String sql = SELECT_BASE + "WHERE e.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ═══════════════════════════════════════════════
    // CREATE
    // ═══════════════════════════════════════════════

    public boolean createEvent(Event event) {
        String sql = "INSERT INTO `event` " +
                     "(id, title, description, startsAt, endsAt, maxlimit, status, location, image) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, java.util.UUID.randomUUID().toString());
            ps.setString(2, event.getTitle());
            ps.setString(3, event.getDescription());
            ps.setTimestamp(4, event.getStartsAt());
            ps.setTimestamp(5, event.getEndsAt());
            ps.setString(6, event.getMaxLimit());
            ps.setString(7, event.getStatus() != null ? event.getStatus() : "opened");
            ps.setString(8, event.getLocation());
            ps.setString(9, event.getImage());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ═══════════════════════════════════════════════
    // UPDATE
    // ═══════════════════════════════════════════════

    /**
     * Update an event. If event.getImage() is non-empty the image column is
     * also updated; otherwise the existing image is kept.
     */
    public boolean updateEvent(Event event) {
        boolean updateImage = event.getImage() != null && !event.getImage().isEmpty();

        String sql = updateImage
            ? "UPDATE `event` SET title=?, description=?, startsAt=?, endsAt=?, " +
              "maxlimit=?, status=?, location=?, image=? WHERE id=?"
            : "UPDATE `event` SET title=?, description=?, startsAt=?, endsAt=?, " +
              "maxlimit=?, status=?, location=? WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, event.getTitle());
            ps.setString(2, event.getDescription());
            ps.setTimestamp(3, event.getStartsAt());
            ps.setTimestamp(4, event.getEndsAt());
            ps.setString(5, event.getMaxLimit());
            ps.setString(6, event.getStatus());
            ps.setString(7, event.getLocation());

            if (updateImage) {
                ps.setString(8, event.getImage());
                ps.setString(9, event.getId());
            } else {
                ps.setString(8, event.getId());
            }

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ═══════════════════════════════════════════════
    // DELETE
    // ═══════════════════════════════════════════════

    /** Set the image column to NULL for an event. */
    public boolean clearEventImage(String id) {
        String sql = "UPDATE `event` SET image = NULL WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Delete an event (cascade deletes volunteer registrations via FK). */
    public boolean deleteEvent(String id) {
        String sql = "DELETE FROM `event` WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ═══════════════════════════════════════════════
    // STATISTICS (used by dashboard + events page header)
    // ═══════════════════════════════════════════════

    public int countTotalEvents() {
        return countWhere("1=1");
    }

    public int countOpenEvents() {
        return countWhere("status = 'opened'");
    }

    /** Events whose start date falls in the current calendar month. */
    public int countEventsThisMonth() {
        return countWhere(
            "MONTH(startsAt) = MONTH(CURDATE()) AND YEAR(startsAt) = YEAR(CURDATE())");
    }

    /** Total accepted volunteer registrations across ALL events. */
    public int countTotalRegistrations() {
        String sql = "SELECT COUNT(*) FROM `volunteer` WHERE status = 'accepted'";
        try (Connection conn = DBConnection.getConnection();
             Statement  st   = conn.createStatement()) {
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

    private int countWhere(String condition) {
        String sql = "SELECT COUNT(*) FROM `event` WHERE " + condition;
        try (Connection conn = DBConnection.getConnection();
             Statement  st   = conn.createStatement()) {
            ResultSet rs = st.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Event mapRow(ResultSet rs) throws SQLException {
        Event e = new Event();
        e.setId(rs.getString("id"));
        e.setTitle(rs.getString("title"));
        e.setDescription(rs.getString("description"));
        e.setStartsAt(rs.getTimestamp("startsAt"));
        e.setEndsAt(rs.getTimestamp("endsAt"));
        e.setMaxLimit(rs.getString("maxlimit"));
        e.setStatus(rs.getString("status"));
        e.setCreatedAt(rs.getTimestamp("createdAt"));
        e.setUpdatedAt(rs.getTimestamp("updatedAt"));
        e.setVolunteerCount(rs.getInt("volunteerCount"));

        // location and image are nullable optional columns
        try { e.setLocation(rs.getString("location")); } catch (SQLException ignored) {}
        try { e.setImage(rs.getString("image"));       } catch (SQLException ignored) {}

        return e;
    }
}

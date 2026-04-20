package com.VMS.dao;

import com.VMS.config.DBConnection;
import com.VMS.model.EventVolunteerEntry;
import com.VMS.model.VolunteerAssignmentEntry;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Manages the assignment table (attendance tracking + reward points).
 *
 * Run this DDL once in MySQL before using:
 *
 *   ALTER TABLE `user` ADD COLUMN rewardPoints INT DEFAULT 0;
 *
 *   CREATE TABLE `assignment` (
 *       id           VARCHAR(36) PRIMARY KEY,
 *       userId       VARCHAR(36) NOT NULL,
 *       eventId      VARCHAR(36) NOT NULL,
 *       attended     BOOLEAN     DEFAULT FALSE,
 *       pointsEarned INT         DEFAULT 0,
 *       markedAt     DATETIME    NULL,
 *       FOREIGN KEY (userId)  REFERENCES `user`(id)  ON DELETE CASCADE,
 *       FOREIGN KEY (eventId) REFERENCES `event`(id) ON DELETE CASCADE,
 *       UNIQUE KEY uq_assignment (userId, eventId)
 *   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 *
 * Points awarded on attendance:
 *   - 10 pts base per event
 *   - +5  bonus for first event ever
 *   - +10 bonus every 3rd event (3rd, 6th, 9th, ...)
 */
public class AssignmentDAO {

    // ═══════════════════════════════════════════════
    // CREATE
    // ═══════════════════════════════════════════════

    /** Insert an assignment record when a volunteer is accepted. Idempotent. */
    public boolean createAssignment(String userId, String eventId) {
        String check = "SELECT id FROM `assignment` WHERE userId=? AND eventId=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(check)) {
            ps.setString(1, userId);
            ps.setString(2, eventId);
            if (ps.executeQuery().next()) return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        String sql = "INSERT INTO `assignment` (id, userId, eventId, attended, pointsEarned) VALUES (?,?,?,FALSE,0)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, UUID.randomUUID().toString());
            ps.setString(2, userId);
            ps.setString(3, eventId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ═══════════════════════════════════════════════
    // MARK ATTENDANCE + AWARD / REVOKE POINTS
    // ═══════════════════════════════════════════════

    /**
     * Mark attended/absent and adjust reward points.
     * Returns points awarded (positive) or 0 if marked absent.
     */
    public int markAttendance(String userId, String eventId, boolean attended) {
        if (attended) {
            int prevCount    = countAttended(userId);
            int newCount     = prevCount + 1;
            int pointsAwarded = 10;
            if (newCount == 1)         pointsAwarded += 5;   // first-event bonus
            if (newCount % 3 == 0)     pointsAwarded += 10;  // milestone bonus

            String updateAssign = "UPDATE `assignment` SET attended=TRUE, pointsEarned=?, markedAt=NOW()" +
                                  " WHERE userId=? AND eventId=?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(updateAssign)) {
                ps.setInt(1, pointsAwarded);
                ps.setString(2, userId);
                ps.setString(3, eventId);
                if (ps.executeUpdate() == 0) return 0;
            } catch (SQLException e) {
                e.printStackTrace();
                return 0;
            }

            String addPts = "UPDATE `user` SET rewardPoints = rewardPoints + ? WHERE id=?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(addPts)) {
                ps.setInt(1, pointsAwarded);
                ps.setString(2, userId);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return pointsAwarded;

        } else {
            int prevPoints = getPointsForAssignment(userId, eventId);

            String updateAssign = "UPDATE `assignment` SET attended=FALSE, pointsEarned=0, markedAt=NOW()" +
                                  " WHERE userId=? AND eventId=?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(updateAssign)) {
                ps.setString(1, userId);
                ps.setString(2, eventId);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }

            if (prevPoints > 0) {
                String removePts = "UPDATE `user` SET rewardPoints = GREATEST(0, rewardPoints - ?) WHERE id=?";
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(removePts)) {
                    ps.setInt(1, prevPoints);
                    ps.setString(2, userId);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            return 0;
        }
    }

    // ═══════════════════════════════════════════════
    // ADMIN PAGE QUERIES
    // ═══════════════════════════════════════════════

    /**
     * All events with pending / accepted / attended counts for the admin assignments list.
     */
    public List<Map<String, Object>> getEventsWithAssignmentStats() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT e.id, e.title, e.location, e.startsAt, e.endsAt, e.status, " +
            "  COUNT(CASE WHEN v.status='pending'  THEN 1 END) AS pendingCount,  " +
            "  COUNT(CASE WHEN v.status='accepted' THEN 1 END) AS acceptedCount, " +
            "  COUNT(CASE WHEN a.attended=TRUE     THEN 1 END) AS attendedCount  " +
            "FROM `event` e " +
            "LEFT JOIN `volunteer` v  ON v.eventId = e.id " +
            "LEFT JOIN `assignment` a ON a.eventId = e.id " +
            "GROUP BY e.id ORDER BY e.startsAt DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement  st   = conn.createStatement()) {
            ResultSet rs  = st.executeQuery(sql);
            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
            Timestamp now = new Timestamp(System.currentTimeMillis());
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id",            rs.getString("id"));
                row.put("title",         nvl(rs.getString("title")));
                row.put("location",      nvl(rs.getString("location")));
                row.put("status",        nvl(rs.getString("status")));
                Timestamp startsAt = rs.getTimestamp("startsAt");
                Timestamp endsAt   = rs.getTimestamp("endsAt");
                row.put("startsAt",      startsAt != null ? sdf.format(startsAt) : "");
                row.put("endsAt",        endsAt   != null ? sdf.format(endsAt)   : "");
                row.put("isPast",        endsAt   != null && endsAt.before(now));
                row.put("pendingCount",  rs.getInt("pendingCount"));
                row.put("acceptedCount", rs.getInt("acceptedCount"));
                row.put("attendedCount", rs.getInt("attendedCount"));
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * All volunteers (all statuses) for one event, enriched with assignment data.
     * Order: pending → accepted → declined.
     */
    public List<EventVolunteerEntry> getVolunteersForEvent(String eventId) {
        List<EventVolunteerEntry> list = new ArrayList<>();
        String sql =
            "SELECT v.userId, v.status AS volunteerStatus, v.joinedAt, " +
            "       u.firstName, u.lastName, u.email, u.phone, u.image, u.username, " +
            "       a.attended, a.pointsEarned, a.markedAt, " +
            "       (a.id IS NOT NULL) AS hasAssignment " +
            "FROM `volunteer` v " +
            "JOIN  `user` u  ON v.userId  = u.id " +
            "LEFT JOIN `assignment` a ON a.userId=v.userId AND a.eventId=v.eventId " +
            "WHERE v.eventId = ? " +
            "ORDER BY FIELD(v.status,'pending','accepted','declined')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eventId);
            ResultSet rs = ps.executeQuery();
            SimpleDateFormat dtFmt  = new SimpleDateFormat("MMM dd, yyyy HH:mm");
            SimpleDateFormat dateFmt = new SimpleDateFormat("MMM dd, yyyy");
            while (rs.next()) {
                EventVolunteerEntry e = new EventVolunteerEntry();
                e.setUserId         (rs.getString("userId"));
                e.setFirstName      (nvl(rs.getString("firstName")));
                e.setLastName       (nvl(rs.getString("lastName")));
                e.setEmail          (nvl(rs.getString("email")));
                e.setPhone          (nvl(rs.getString("phone")));
                e.setImage          (nvl(rs.getString("image")));
                e.setUsername       (nvl(rs.getString("username")));
                e.setVolunteerStatus(nvl(rs.getString("volunteerStatus")));
                e.setAttended       (rs.getBoolean("attended"));
                e.setHasAssignment  (rs.getBoolean("hasAssignment"));
                e.setPointsEarned   (rs.getInt("pointsEarned"));
                Timestamp markedAt = rs.getTimestamp("markedAt");
                Timestamp joinedAt = rs.getTimestamp("joinedAt");
                e.setMarkedAt(markedAt != null ? dtFmt.format(markedAt)   : "");
                e.setJoinedAt(joinedAt != null ? dateFmt.format(joinedAt) : "");
                list.add(e);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ═══════════════════════════════════════════════
    // VOLUNTEER PAGE QUERIES
    // ═══════════════════════════════════════════════

    /** All accepted events for a volunteer, ordered upcoming first then past. */
    public List<VolunteerAssignmentEntry> getAssignmentsForVolunteer(String userId) {
        List<VolunteerAssignmentEntry> list = new ArrayList<>();
        String sql =
            "SELECT e.id AS eventId, e.title, e.location, e.startsAt, e.endsAt, e.status AS eventStatus, " +
            "       v.joinedAt, a.attended, a.pointsEarned, a.markedAt, " +
            "       (a.id IS NOT NULL) AS hasAssignment " +
            "FROM `volunteer` v " +
            "JOIN  `event` e ON v.eventId = e.id " +
            "LEFT JOIN `assignment` a ON a.userId=v.userId AND a.eventId=v.eventId " +
            "WHERE v.userId=? AND v.status='accepted' " +
            "ORDER BY e.endsAt > NOW() DESC, e.startsAt ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            SimpleDateFormat dtFmt   = new SimpleDateFormat("MMM dd, yyyy HH:mm");
            SimpleDateFormat dateFmt = new SimpleDateFormat("MMM dd, yyyy");
            Timestamp now = new Timestamp(System.currentTimeMillis());
            while (rs.next()) {
                VolunteerAssignmentEntry e = new VolunteerAssignmentEntry();
                e.setEventId     (nvl(rs.getString("eventId")));
                e.setTitle       (nvl(rs.getString("title")));
                e.setLocation    (nvl(rs.getString("location")));
                e.setEventStatus (nvl(rs.getString("eventStatus")));
                Timestamp startsAt = rs.getTimestamp("startsAt");
                Timestamp endsAt   = rs.getTimestamp("endsAt");
                Timestamp joinedAt = rs.getTimestamp("joinedAt");
                Timestamp markedAt = rs.getTimestamp("markedAt");
                e.setStartsAt   (startsAt != null ? dtFmt.format(startsAt)     : "");
                e.setEndsAt     (endsAt   != null ? dtFmt.format(endsAt)       : "");
                e.setJoinedAt   (joinedAt != null ? dateFmt.format(joinedAt)   : "");
                e.setMarkedAt   (markedAt != null ? dateFmt.format(markedAt)   : "");
                e.setAttended   (rs.getBoolean("attended"));
                e.setHasAssignment(rs.getBoolean("hasAssignment"));
                e.setPointsEarned(rs.getInt("pointsEarned"));
                e.setPast       (endsAt != null && endsAt.before(now));
                list.add(e);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ═══════════════════════════════════════════════
    // STATISTICS
    // ═══════════════════════════════════════════════

    public int countTotalAttended() {
        return queryCount("SELECT COUNT(*) FROM `assignment` WHERE attended=TRUE");
    }

    public int countTotalPointsAwarded() {
        return queryCount("SELECT COALESCE(SUM(rewardPoints),0) FROM `user` WHERE role='volunteer'");
    }

    // ═══════════════════════════════════════════════
    // PRIVATE HELPERS
    // ═══════════════════════════════════════════════

    private int countAttended(String userId) {
        String sql = "SELECT COUNT(*) FROM `assignment` WHERE userId=? AND attended=TRUE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int getPointsForAssignment(String userId, String eventId) {
        String sql = "SELECT pointsEarned FROM `assignment` WHERE userId=? AND eventId=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int queryCount(String sql) {
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private static String nvl(String s) { return s != null ? s : ""; }
}

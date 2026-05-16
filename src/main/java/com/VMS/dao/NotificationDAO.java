package com.VMS.dao;

import com.VMS.config.DBConnection;
import com.VMS.model.VolunteerNotification;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * DAO for the `notification` table.
 *
 * Run this DDL once (drop & recreate if the old table exists):
 *
 *   DROP TABLE IF EXISTS `notification`;
 *
 *   CREATE TABLE `notification` (
 *       id            VARCHAR(36)  PRIMARY KEY,
 *       recipientId   VARCHAR(36)  NULL,        -- NULL = broadcast to all admins
 *       actorId       VARCHAR(36)  NULL,         -- who triggered it
 *       eventId       VARCHAR(36)  NULL,         -- NULL for registration notifications
 *       type          VARCHAR(30)  NOT NULL,     -- accepted | declined | new_registration | event_request
 *       recipientRole VARCHAR(20)  NOT NULL,     -- 'volunteer' | 'admin'
 *       message       VARCHAR(500) DEFAULT '',
 *       isRead        BOOLEAN      DEFAULT FALSE,
 *       createdAt     DATETIME     DEFAULT CURRENT_TIMESTAMP,
 *       FOREIGN KEY (recipientId) REFERENCES `user`(id)  ON DELETE CASCADE,
 *       FOREIGN KEY (actorId)     REFERENCES `user`(id)  ON DELETE SET NULL,
 *       FOREIGN KEY (eventId)     REFERENCES `event`(id) ON DELETE CASCADE
 *   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 */
public class NotificationDAO {

    public boolean insertNotification(String recipientId, String actorId,
                                      String eventId,    String type,
                                      String recipientRole, String message) {
        String sql =
            "INSERT INTO `notification` " +
            "(id, recipientId, actorId, eventId, type, recipientRole, message, isRead, createdAt) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, FALSE, NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, UUID.randomUUID().toString());
            ps.setString(2, recipientId);   // nullable
            ps.setString(3, actorId);       // nullable
            ps.setString(4, eventId);       // nullable
            ps.setString(5, type);
            ps.setString(6, recipientRole);
            ps.setString(7, message != null ? message : "");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<VolunteerNotification> getNotificationsForVolunteer(String userId, int limit) {
        String sql =
            "SELECT n.id, n.type, n.message, n.isRead, n.createdAt, n.recipientRole, " +
            "       e.id AS eventId, e.title AS eventTitle, " +
            "       u.firstName AS actorFirst, u.lastName AS actorLast " +
            "FROM `notification` n " +
            "LEFT JOIN `event` e ON n.eventId  = e.id " +
            "LEFT JOIN `user`  u ON n.actorId  = u.id " +
            "WHERE n.recipientRole='volunteer' AND n.recipientId=? " +
            "ORDER BY n.createdAt DESC LIMIT ?";
        return fetch(sql, userId, limit);
    }

    public List<VolunteerNotification> getNotificationsForAdmin(int limit) {
        String sql =
            "SELECT n.id, n.type, n.message, n.isRead, n.createdAt, n.recipientRole, " +
            "       e.id AS eventId, e.title AS eventTitle, " +
            "       u.firstName AS actorFirst, u.lastName AS actorLast " +
            "FROM `notification` n " +
            "LEFT JOIN `event` e ON n.eventId = e.id " +
            "LEFT JOIN `user`  u ON n.actorId = u.id " +
            "WHERE n.recipientRole='admin' " +
            "ORDER BY n.createdAt DESC LIMIT ?";
        return fetch(sql, null, limit);
    }

    public int countUnreadForVolunteer(String userId) {
        return countUnread(
            "SELECT COUNT(*) FROM `notification` " +
            "WHERE recipientRole='volunteer' AND recipientId=? AND isRead=FALSE",
            userId
        );
    }

    public int countUnreadForAdmin() {
        return countUnread(
            "SELECT COUNT(*) FROM `notification` WHERE recipientRole='admin' AND isRead=FALSE",
            null
        );
    }

    public void markAllReadForVolunteer(String userId) {
        exec("UPDATE `notification` SET isRead=TRUE " +
             "WHERE recipientRole='volunteer' AND recipientId=? AND isRead=FALSE", userId);
    }

    public void markAllReadForAdmin() {
        exec("UPDATE `notification` SET isRead=TRUE " +
             "WHERE recipientRole='admin' AND isRead=FALSE", null);
    }

    // ── private helpers ──

    private List<VolunteerNotification> fetch(String sql, String param, int limit) {
        List<VolunteerNotification> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            if (param != null) ps.setString(idx++, param);
            ps.setInt(idx, limit);
            ResultSet rs = ps.executeQuery();
            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
            while (rs.next()) {
                VolunteerNotification n = new VolunteerNotification();
                n.setId(rs.getString("id"));
                n.setEventId(rs.getString("eventId"));
                n.setEventTitle(nvl(rs.getString("eventTitle")));
                n.setStatus(rs.getString("type"));
                n.setRecipientRole(nvl(rs.getString("recipientRole")));
                n.setMessage(nvl(rs.getString("message")));
                n.setRead(rs.getBoolean("isRead"));
                String first = nvl(rs.getString("actorFirst"));
                String last  = nvl(rs.getString("actorLast"));
                n.setActorName((first + " " + last).trim());
                Timestamp ts = rs.getTimestamp("createdAt");
                n.setUpdatedAt(ts != null ? sdf.format(ts) : "");
                list.add(n);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private int countUnread(String sql, String param) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (param != null) ps.setString(1, param);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private void exec(String sql, String param) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (param != null) ps.setString(1, param);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static String nvl(String s) { return s != null ? s : ""; }
}

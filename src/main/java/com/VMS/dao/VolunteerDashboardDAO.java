package com.VMS.dao;

import com.VMS.config.DBConnection;
import java.sql.*;

public class VolunteerDashboardDAO {

    public int countEventsAttended(String userId) {
        return query("SELECT COUNT(*) FROM `assignment` WHERE userId=? AND attended=TRUE", userId);
    }

    public int countUpcomingEvents(String userId) {
        String sql =
            "SELECT COUNT(*) FROM `volunteer` v " +
            "JOIN `event` e ON v.eventId=e.id " +
            "WHERE v.userId=? AND v.status='accepted' AND e.endsAt > NOW()";
        return query(sql, userId);
    }

    public int getTotalHoursServed(String userId) {
        String sql =
            "SELECT COALESCE(SUM(TIMESTAMPDIFF(HOUR, e.startsAt, e.endsAt)), 0) " +
            "FROM `assignment` a JOIN `event` e ON a.eventId=e.id " +
            "WHERE a.userId=? AND a.attended=TRUE";
        return query(sql, userId);
    }

    /** Badges = 1 per 50 reward points earned. */
    public int countBadgesEarned(String userId) {
        String sql = "SELECT FLOOR(COALESCE(rewardPoints,0)/50) FROM `user` WHERE id=?";
        return query(sql, userId);
    }

    public int getRewardPoints(String userId) {
        String sql = "SELECT COALESCE(rewardPoints,0) FROM `user` WHERE id=?";
        return query(sql, userId);
    }

    private int query(String sql, String userId) {
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
}

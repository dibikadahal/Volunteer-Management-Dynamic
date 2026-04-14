package com.VMS.dao;

/**
 * Volunteer dashboard statistics.
 * Events / assignments / hours / badges all return 0 until those tables are created.
 * Replace each TODO block with a real query once the table exists.
 */
public class VolunteerDashboardDAO {

    public int countEventsAttended(String userId) {
        // TODO: SELECT COUNT(*) FROM assignment WHERE userId=? AND status='attended'
        return 0;
    }

    public int countUpcomingEvents(String userId) {
        // TODO: SELECT COUNT(*) FROM assignment a JOIN event e ON a.eventId=e.id
        //       WHERE a.userId=? AND e.eventDate >= CURDATE() AND a.status='registered'
        return 0;
    }

    public int getTotalHoursServed(String userId) {
        // TODO: SELECT COALESCE(SUM(e.durationHours),0) FROM assignment a
        //       JOIN event e ON a.eventId=e.id WHERE a.userId=? AND a.status='attended'
        return 0;
    }

    public int countBadgesEarned(String userId) {
        // TODO: SELECT COUNT(*) FROM user_badge WHERE userId=?
        return 0;
    }
}

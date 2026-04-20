package com.VMS.controller;

import com.VMS.dao.AdminDashboardDAO;
import com.VMS.dao.EventDAO;
import com.VMS.dao.VolunteerDAO;
import com.VMS.dao.VolunteerDashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet({"/admin/dashboard", "/volunteer/dashboard"})
public class DashboardController extends HttpServlet {

    private final AdminDashboardDAO     adminDao     = new AdminDashboardDAO();
    private final VolunteerDashboardDAO volunteerDao = new VolunteerDashboardDAO();
    private final VolunteerDAO          volDao       = new VolunteerDAO();
    private final EventDAO              eventDao     = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        String path = request.getServletPath();

        // Role guard
        if (path.equals("/admin/dashboard") && !"admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/volunteer/dashboard");
            return;
        }
        if (path.equals("/volunteer/dashboard") && !"volunteer".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        if (path.equals("/admin/dashboard")) {

            // ── Volunteer stats ──
            request.setAttribute("totalVolunteers",   adminDao.countTotalVolunteers());
            request.setAttribute("activeVolunteers",  adminDao.countActiveVolunteers());
            request.setAttribute("pendingCount",      adminDao.countPendingVolunteers());

            // ── Event stats ──
            request.setAttribute("eventsThisMonth",   eventDao.countEventsThisMonth());
            request.setAttribute("openEvents",        eventDao.countOpenEvents());
            request.setAttribute("totalEvents",       eventDao.countTotalEvents());

            // ── Pending registration requests ──
            request.setAttribute("pendingVolunteers", adminDao.getPendingVolunteers());

            // ── Recent approved volunteers (for the bottom panel) ──
            request.setAttribute("recentVolunteers",  adminDao.getRecentApprovedVolunteers(5));

            request.getRequestDispatcher("/WEB-INF/pages/admin/dashboard.jsp")
                   .forward(request, response);

        } else if (path.equals("/volunteer/dashboard")) {

            String userId = (String) session.getAttribute("userId");

            request.setAttribute("totalAttended",  volunteerDao.countEventsAttended(userId));
            request.setAttribute("upcomingCount",  volunteerDao.countUpcomingEvents(userId));
            request.setAttribute("hoursServed",    volunteerDao.getTotalHoursServed(userId));
            request.setAttribute("badgesEarned",   volunteerDao.countBadgesEarned(userId));
            request.setAttribute("rewardPoints",   volunteerDao.getRewardPoints(userId));
            request.setAttribute("notifications",  volDao.getStatusNotifications(userId));

            request.getRequestDispatcher("/WEB-INF/pages/volunteer/dashboard.jsp")
                   .forward(request, response);
        }
    }
}

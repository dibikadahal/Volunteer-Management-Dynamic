package com.VMS.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet({"/admin/dashboard", "/volunteer/dashboard"})
public class DashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // ── Session guard — redirect to login if not logged in ──
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        String path = request.getServletPath();

        // ── Role guard — prevent wrong role accessing wrong dashboard ──
        if (path.equals("/admin/dashboard") && !"admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/volunteer/dashboard");
            return;
        }

        if (path.equals("/volunteer/dashboard") && !"volunteer".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        // ── Forward to correct dashboard ──
        if (path.equals("/admin/dashboard")) {
            // TODO: set admin stats from DAO here when ready
            // e.g. request.setAttribute("totalVolunteers", adminDao.countVolunteers());
            request.getRequestDispatcher("/WEB-INF/pages/admin/dashboard.jsp")
                   .forward(request, response);

        } else if (path.equals("/volunteer/dashboard")) {
            // TODO: replace these with real DAO calls when ready:
            // String userId = (String) session.getAttribute("userId");
            // request.setAttribute("totalAttended", volunteerDao.countAttended(userId));
            // request.setAttribute("upcomingCount",  volunteerDao.countUpcoming(userId));
            // request.setAttribute("hoursServed",    volunteerDao.getTotalHours(userId));
            // request.setAttribute("badgesEarned",   volunteerDao.countBadges(userId));

            // Placeholder values for now
            request.setAttribute("totalAttended", 12);
            request.setAttribute("upcomingCount",  4);
            request.setAttribute("hoursServed",    38);
            request.setAttribute("badgesEarned",   3);

            request.getRequestDispatcher("/WEB-INF/pages/volunteer/dashboard.jsp")
                   .forward(request, response);
        }
    }
}
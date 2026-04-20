package com.VMS.controller;

import com.VMS.dao.AdminDashboardDAO;
import com.VMS.dao.AssignmentDAO;
import com.VMS.dao.VolunteerDAO;
import com.VMS.model.EventVolunteerEntry;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/assignments")
public class AdminAssignmentController extends HttpServlet {

    private final AssignmentDAO     assignmentDao = new AssignmentDAO();
    private final VolunteerDAO      volunteerDao  = new VolunteerDAO();
    private final AdminDashboardDAO adminDao      = new AdminDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Map<String, Object>> events = assignmentDao.getEventsWithAssignmentStats();
        request.setAttribute("events",            events);
        request.setAttribute("totalEvents",        events.size());
        request.setAttribute("totalAttended",      assignmentDao.countTotalAttended());
        request.setAttribute("totalPointsAwarded", assignmentDao.countTotalPointsAwarded());
        request.setAttribute("pendingCount",       adminDao.countPendingVolunteers());

        String selectedEventId = request.getParameter("eventId");
        if (selectedEventId != null && !selectedEventId.trim().isEmpty()) {
            List<EventVolunteerEntry> eventVolunteers = assignmentDao.getVolunteersForEvent(selectedEventId);
            request.setAttribute("eventVolunteers",  eventVolunteers);
            request.setAttribute("selectedEventId",  selectedEventId);

            for (Map<String, Object> ev : events) {
                if (selectedEventId.equals(ev.get("id"))) {
                    request.setAttribute("selectedEvent", ev);
                    break;
                }
            }
        }

        request.getRequestDispatcher("/WEB-INF/pages/admin/assignments.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action  = request.getParameter("action");
        String userId  = request.getParameter("userId");
        String eventId = request.getParameter("eventId");

        String base = request.getContextPath() + "/admin/assignments?eventId=" + eventId;

        if (userId == null || eventId == null || action == null) {
            response.sendRedirect(base + "&error=Missing+parameters");
            return;
        }

        switch (action) {
            case "accept":
                boolean ok = volunteerDao.updateVolunteerStatus(userId, eventId, "accepted");
                if (ok) assignmentDao.createAssignment(userId, eventId);
                response.sendRedirect(base + (ok ? "&success=Volunteer+accepted" : "&error=Failed+to+accept"));
                break;

            case "decline":
                boolean dk = volunteerDao.updateVolunteerStatus(userId, eventId, "declined");
                response.sendRedirect(base + (dk ? "&success=Volunteer+declined" : "&error=Failed+to+decline"));
                break;

            case "mark-attended":
                assignmentDao.markAttendance(userId, eventId, true);
                response.sendRedirect(base + "&success=Marked+as+attended+and+points+awarded");
                break;

            case "mark-absent":
                assignmentDao.markAttendance(userId, eventId, false);
                response.sendRedirect(base + "&success=Marked+as+absent");
                break;

            default:
                response.sendRedirect(base + "&error=Unknown+action");
        }
    }
}

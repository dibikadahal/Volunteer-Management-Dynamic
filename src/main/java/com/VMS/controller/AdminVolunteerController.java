package com.VMS.controller;

import java.io.IOException;
import com.VMS.dao.AssignmentDAO;
import com.VMS.dao.VolunteerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet({"/admin/approve-volunteer", "/admin/decline-volunteer"})
public class AdminVolunteerController extends HttpServlet {

    private final VolunteerDAO  volunteerDao  = new VolunteerDAO();
    private final AssignmentDAO assignmentDao = new AssignmentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check if user is admin
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized");
            return;
        }

        String path = request.getServletPath();
        String userId = request.getParameter("userId");
        String eventId = request.getParameter("eventId");

        if (userId == null || eventId == null) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=Missing+parameters");
            return;
        }

        boolean success = false;

        if (path.equals("/admin/approve-volunteer")) {
            success = volunteerDao.updateVolunteerStatus(userId, eventId, "accepted");
            if (success) assignmentDao.createAssignment(userId, eventId);
        } else if (path.equals("/admin/decline-volunteer")) {
            success = volunteerDao.updateVolunteerStatus(userId, eventId, "declined");
        }

        String message = success ? "Volunteer+status+updated" : "Failed+to+update+status";
        String param   = success ? "success=" : "error=";
        response.sendRedirect(request.getContextPath() + "/admin/dashboard?" + param + message);
    }
}






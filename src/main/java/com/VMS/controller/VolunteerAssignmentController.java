package com.VMS.controller;

import com.VMS.dao.AssignmentDAO;
import com.VMS.model.VolunteerAssignmentEntry;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/volunteer/assignments")
public class VolunteerAssignmentController extends HttpServlet {

    private final AssignmentDAO assignmentDao = new AssignmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!"volunteer".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        List<VolunteerAssignmentEntry> all = assignmentDao.getAssignmentsForVolunteer(userId);

        List<VolunteerAssignmentEntry> upcoming = new ArrayList<>();
        List<VolunteerAssignmentEntry> past     = new ArrayList<>();
        int totalPoints  = 0;
        int totalAttended = 0;

        for (VolunteerAssignmentEntry a : all) {
            if (a.isPast()) {
                past.add(a);
                totalPoints += a.getPointsEarned();
                if (a.isAttended()) totalAttended++;
            } else {
                upcoming.add(a);
            }
        }

        request.setAttribute("upcoming",      upcoming);
        request.setAttribute("past",          past);
        request.setAttribute("totalPoints",   totalPoints);
        request.setAttribute("totalAccepted", all.size());
        request.setAttribute("totalAttended", totalAttended);

        request.getRequestDispatcher("/WEB-INF/pages/volunteer/assignments.jsp")
               .forward(request, response);
    }
}

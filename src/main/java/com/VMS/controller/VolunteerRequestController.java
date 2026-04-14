package com.VMS.controller;

import com.VMS.dao.AdminDashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Handles admin approve / decline actions for pending volunteer registrations.
 * POST /admin/volunteer-requests?action=approve&id=...
 * POST /admin/volunteer-requests?action=decline&id=...
 */
@WebServlet("/admin/volunteer-requests")
public class VolunteerRequestController extends HttpServlet {

    private final AdminDashboardDAO dao = new AdminDashboardDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Admin-only guard
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        String id     = request.getParameter("id");

        if (id == null || id.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath()
                + "/admin/dashboard?error=Invalid+request");
            return;
        }

        if ("approve".equals(action)) {
            boolean ok = dao.approveVolunteer(id.trim());
            if (ok) {
                response.sendRedirect(request.getContextPath()
                    + "/admin/dashboard?success=Volunteer+approved+successfully");
            } else {
                response.sendRedirect(request.getContextPath()
                    + "/admin/dashboard?error=Could+not+approve+volunteer");
            }

        } else if ("decline".equals(action)) {
            boolean ok = dao.declineVolunteer(id.trim());
            if (ok) {
                response.sendRedirect(request.getContextPath()
                    + "/admin/dashboard?success=Registration+declined+and+removed");
            } else {
                response.sendRedirect(request.getContextPath()
                    + "/admin/dashboard?error=Could+not+decline+volunteer");
            }

        } else {
            response.sendRedirect(request.getContextPath()
                + "/admin/dashboard?error=Unknown+action");
        }
    }
}

package com.VMS.controller;

import com.VMS.dao.NotificationDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Marks notifications as read in the DB when a user opens their bell dropdown.
 * Handles both volunteer (/volunteer/notifications/mark-read)
 * and admin      (/admin/notifications/mark-read).
 */
@WebServlet({"/volunteer/notifications/mark-read", "/admin/notifications/mark-read"})
public class NotificationController extends HttpServlet {

    private final NotificationDAO notificationDao = new NotificationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String role   = (String) session.getAttribute("userRole");
        String userId = (String) session.getAttribute("userId");

        if ("volunteer".equals(role) && userId != null) {
            notificationDao.markAllReadForVolunteer(userId);
        } else if ("admin".equals(role)) {
            notificationDao.markAllReadForAdmin();
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        response.setStatus(HttpServletResponse.SC_OK);
    }
}

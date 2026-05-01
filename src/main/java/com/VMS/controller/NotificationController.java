package com.VMS.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Marks volunteer notifications as read by storing the last-seen count in the session.
 * Called via fetch() when the notification dropdown is opened.
 */
@WebServlet("/volunteer/notifications/mark-read")
public class NotificationController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"volunteer".equals(session.getAttribute("userRole"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String countParam = request.getParameter("count");
        if (countParam != null) {
            try {
                int count = Integer.parseInt(countParam.trim());
                session.setAttribute("notifLastSeenCount", count);
            } catch (NumberFormatException ignored) {}
        }
        response.setStatus(HttpServletResponse.SC_OK);
    }
}

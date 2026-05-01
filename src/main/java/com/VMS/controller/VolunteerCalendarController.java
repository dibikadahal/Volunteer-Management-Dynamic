package com.VMS.controller;

import com.VMS.dao.EventDAO;
import com.VMS.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/volunteer/calendar")
public class VolunteerCalendarController extends HttpServlet {

    private final EventDAO eventDao = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"volunteer".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        // Fetch all events with this volunteer's personal status on each
        List<Event> events = eventDao.getAllEventsWithStatus(userId, null, "startsAt", "asc");
        request.setAttribute("events", events);
        request.getRequestDispatcher("/WEB-INF/pages/volunteer/calendar.jsp")
               .forward(request, response);
    }
}

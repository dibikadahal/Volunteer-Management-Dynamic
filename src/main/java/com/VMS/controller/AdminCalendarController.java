package com.VMS.controller;

import com.VMS.dao.EventDAO;
import com.VMS.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/calendar")
public class AdminCalendarController extends HttpServlet {

    private final EventDAO eventDao = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Event> events = eventDao.getAllEvents(null, "startsAt", "asc");
        request.setAttribute("events", events);
        request.getRequestDispatcher("/WEB-INF/pages/admin/calendar.jsp")
               .forward(request, response);
    }
}

package com.VMS.controller;

import com.VMS.dao.AdminDashboardDAO;
import com.VMS.dao.AssignmentDAO;
import com.VMS.dao.EventDAO;
import com.VMS.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/home")
public class LandingController extends HttpServlet {

    private final EventDAO          eventDAO    = new EventDAO();
    private final AdminDashboardDAO adminDAO    = new AdminDashboardDAO();
    private final AssignmentDAO     assignDAO   = new AssignmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Featured events: upcoming + ongoing only (not finished), max 6
        List<Event> allEvents = eventDAO.getAllEvents(null, "startsAt", "asc");
        List<Event> featured  = new ArrayList<>();
        for (Event e : allEvents) {
            if (!"finished".equals(e.getDerivedStatus())) {
                featured.add(e);
                if (featured.size() == 6) break;
            }
        }

        // Real-time stats for hero section
        int activeVolunteers = adminDAO.countActiveVolunteers();
        int totalEvents      = eventDAO.countTotalEvents();
        int hoursServed      = assignDAO.getTotalHoursServedAll();
        int totalAttended    = assignDAO.countTotalAttended();

        req.setAttribute("featuredEvents",    featured);
        req.setAttribute("activeVolunteers",  activeVolunteers);
        req.setAttribute("totalEvents",       totalEvents);
        req.setAttribute("hoursServed",       hoursServed);
        req.setAttribute("totalAttended",     totalAttended);

        req.getRequestDispatcher("/WEB-INF/pages/landing.jsp").forward(req, res);
    }
}

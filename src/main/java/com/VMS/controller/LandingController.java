package com.VMS.controller;

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

    private final EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        List<Event> allEvents = eventDAO.getAllEvents(null, "startsAt", "asc");

        List<Event> featured = new ArrayList<>();
        for (Event e : allEvents) {
            if ("opened".equals(e.getStatus())) {
                featured.add(e);
                if (featured.size() == 5) break;
            }
        }

        req.setAttribute("featuredEvents", featured);
        req.getRequestDispatcher("/WEB-INF/pages/landing.jsp").forward(req, res);
    }
}

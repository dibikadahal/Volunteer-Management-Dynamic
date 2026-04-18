package com.VMS.controller;

import com.VMS.dao.EventDAO;
import com.VMS.dao.VolunteerDAO;
import com.VMS.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/volunteer/browse-events")
public class VolunteerEventsController extends HttpServlet {

    private final EventDAO     eventDao     = new EventDAO();
    private final VolunteerDAO volunteerDao = new VolunteerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isVolunteer(request, response)) return;

        HttpSession session = request.getSession(false);
        String userId = (String) session.getAttribute("userId");

        String search  = request.getParameter("search");
        String sortBy  = request.getParameter("sortBy");
        String sortDir = request.getParameter("sortDir");

        if (sortBy  == null || sortBy.isBlank())  sortBy  = "createdAt";
        if (sortDir == null || sortDir.isBlank())  sortDir = "desc";

        List<Event> events = eventDao.getAllEventsWithStatus(userId, search, sortBy, sortDir);

        request.setAttribute("events",   events);
        request.setAttribute("search",   search  != null ? search  : "");
        request.setAttribute("sortBy",   sortBy);
        request.setAttribute("sortDir",  sortDir);

        request.getRequestDispatcher("/WEB-INF/pages/volunteer/browseEvents.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isVolunteer(request, response)) return;

        HttpSession session = request.getSession(false);
        String userId  = (String) session.getAttribute("userId");
        String action  = request.getParameter("action");
        String eventId = request.getParameter("eventId");

        if ("request".equals(action) && eventId != null && !eventId.isBlank()) {
            boolean ok = volunteerDao.requestVolunteer(userId, eventId.trim());
            if (ok) {
                response.sendRedirect(request.getContextPath()
                    + "/volunteer/browse-events?success=Your+request+has+been+submitted+successfully%21");
            } else {
                response.sendRedirect(request.getContextPath()
                    + "/volunteer/browse-events?error=You+have+already+submitted+a+request+for+this+event.");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/volunteer/browse-events");
        }
    }

    private boolean isVolunteer(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"volunteer".equals(session.getAttribute("userRole"))) {
            res.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }
}

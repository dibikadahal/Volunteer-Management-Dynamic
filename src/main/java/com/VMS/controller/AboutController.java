package com.VMS.controller;

import com.VMS.dao.AdminDashboardDAO;
import com.VMS.dao.AssignmentDAO;
import com.VMS.dao.EventDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/about")
public class AboutController extends HttpServlet {

    private final EventDAO          eventDAO  = new EventDAO();
    private final AdminDashboardDAO adminDAO  = new AdminDashboardDAO();
    private final AssignmentDAO     assignDAO = new AssignmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setAttribute("activeVolunteers", adminDAO.countActiveVolunteers());
        req.setAttribute("totalEvents",      eventDAO.countTotalEvents());
        req.setAttribute("hoursServed",      assignDAO.getTotalHoursServedAll());
        req.setAttribute("totalAttended",    assignDAO.countTotalAttended());

        req.getRequestDispatcher("/WEB-INF/pages/about.jsp").forward(req, res);
    }
}

package com.VMS.controller;

import com.VMS.dao.AdminDashboardDAO;
import com.VMS.dao.VolunteerManagementDAO;
import com.VMS.model.User;
import com.VMS.model.VolunteerEventEntry;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;

@WebServlet("/admin/volunteers")
public class VolunteerManagementController extends HttpServlet {

    private final VolunteerManagementDAO dao      = new VolunteerManagementDAO();
    private final AdminDashboardDAO      adminDao = new AdminDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String search  = request.getParameter("search");
        String sortBy  = request.getParameter("sortBy");
        String sortDir = request.getParameter("sortDir");

        if (sortBy  == null || sortBy.isBlank())  sortBy  = "createdAt";
        if (sortDir == null || sortDir.isBlank())  sortDir = "desc";

        // Fetch active volunteers with event counts
        List<User> volunteers = dao.getAllActiveVolunteers(search, sortBy, sortDir);

        // Batch-fetch all their events in one query
        List<String> userIds = new ArrayList<>();
        for (User u : volunteers) userIds.add(u.getId());
        Map<String, List<VolunteerEventEntry>> eventsMap = dao.getVolunteerEventsMap(userIds);

        request.setAttribute("volunteers",    volunteers);
        request.setAttribute("eventsMap",     eventsMap);
        request.setAttribute("search",        search  != null ? search  : "");
        request.setAttribute("sortBy",        sortBy);
        request.setAttribute("sortDir",       sortDir);

        // Stats
        request.setAttribute("activeCount",   adminDao.countActiveVolunteers());
        request.setAttribute("pendingCount",  adminDao.countPendingVolunteers());
        request.setAttribute("totalRegs",     dao.countTotalRegistrations());

        request.getRequestDispatcher("/WEB-INF/pages/admin/volunteers.jsp")
               .forward(request, response);
    }

    private boolean isAdmin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            res.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }
}

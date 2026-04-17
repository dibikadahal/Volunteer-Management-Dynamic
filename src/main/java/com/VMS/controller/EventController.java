package com.VMS.controller;

import com.VMS.dao.EventDAO;
import com.VMS.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

import java.io.*;
import java.nio.file.*;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

/**
 * EventController — Admin event management.
 *
 * Routes (registered in web.xml):
 *   GET  /admin/events                → list all events
 *   POST /admin/events?action=create  → create new event
 *   POST /admin/events?action=update  → update existing event
 *   POST /admin/events?action=delete  → delete event
 *
 * Multipart-config is declared in web.xml so file uploads work.
 */
@MultipartConfig
public class EventController extends HttpServlet {

    private final EventDAO eventDao = new EventDAO();

    private static final String[] ALLOWED_IMG = {
        "image/jpeg", "image/png", "image/gif", "image/webp"
    };

    // ── GET: list events ──────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String search  = request.getParameter("search");
        String sortBy  = request.getParameter("sortBy");
        String sortDir = request.getParameter("sortDir");

        // Default sort: newest first
        if (sortBy  == null || sortBy.isBlank())  sortBy  = "createdAt";
        if (sortDir == null || sortDir.isBlank())  sortDir = "desc";

        List<Event> events = eventDao.getAllEvents(search, sortBy, sortDir);

        request.setAttribute("events",           events);
        request.setAttribute("totalEvents",       eventDao.countTotalEvents());
        request.setAttribute("openEvents",        eventDao.countOpenEvents());
        request.setAttribute("eventsThisMonth",   eventDao.countEventsThisMonth());
        request.setAttribute("totalRegistrations",eventDao.countTotalRegistrations());
        request.setAttribute("search",            search   != null ? search   : "");
        request.setAttribute("sortBy",            sortBy);
        request.setAttribute("sortDir",           sortDir);

        request.getRequestDispatcher("/WEB-INF/pages/admin/events.jsp")
               .forward(request, response);
    }

    // ── POST: CRUD actions ────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            handleCreate(request, response);
        } else if ("update".equals(action)) {
            handleUpdate(request, response);
        } else if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/events?error=Unknown+action");
        }
    }

    // ─────────────────────────────────────────────────────────
    // CREATE
    // ─────────────────────────────────────────────────────────
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Event event = buildEventFromRequest(request);
        if (event == null) {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?error=Invalid+date+format.+Please+check+start+and+end+dates.");
            return;
        }

        // Handle image upload
        String imagePath = saveUploadedImage(request, "eventImage");
        if (imagePath != null) event.setImage(imagePath);

        boolean ok = eventDao.createEvent(event);
        if (ok) {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?success=Event+created+successfully");
        } else {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?error=Failed+to+create+event.+Please+try+again.");
        }
    }

    // ─────────────────────────────────────────────────────────
    // UPDATE
    // ─────────────────────────────────────────────────────────
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        if (id == null || id.isBlank()) {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?error=Missing+event+ID");
            return;
        }

        Event event = buildEventFromRequest(request);
        if (event == null) {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?error=Invalid+date+format.+Please+check+start+and+end+dates.");
            return;
        }
        event.setId(id.trim());

        // Handle image upload (if no new image uploaded, existing image is kept)
        String imagePath = saveUploadedImage(request, "eventImage");
        if (imagePath != null) event.setImage(imagePath);

        boolean ok = eventDao.updateEvent(event);
        if (ok) {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?success=Event+updated+successfully");
        } else {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?error=Failed+to+update+event.+Please+try+again.");
        }
    }

    // ─────────────────────────────────────────────────────────
    // DELETE
    // ─────────────────────────────────────────────────────────
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String id = request.getParameter("id");
        if (id == null || id.isBlank()) {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?error=Missing+event+ID");
            return;
        }

        boolean ok = eventDao.deleteEvent(id.trim());
        if (ok) {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?success=Event+deleted+successfully");
        } else {
            response.sendRedirect(request.getContextPath()
                + "/admin/events?error=Failed+to+delete+event.+Please+try+again.");
        }
    }

    // ─────────────────────────────────────────────────────────
    // HELPERS
    // ─────────────────────────────────────────────────────────

    /** Build an Event from POST params. Returns null if required dates are invalid. */
    private Event buildEventFromRequest(HttpServletRequest req) {
        Event e = new Event();
        e.setTitle(    getParam(req, "title"));
        e.setDescription(getParam(req, "description"));
        e.setMaxLimit( getParam(req, "maxLimit"));
        e.setStatus(   getParam(req, "status").isEmpty() ? "opened" : getParam(req, "status"));
        e.setLocation( getParam(req, "location"));

        Timestamp starts = parseDateTime(getParam(req, "startsAt"));
        Timestamp ends   = parseDateTime(getParam(req, "endsAt"));

        if (starts == null || ends == null) return null;

        e.setStartsAt(starts);
        e.setEndsAt(ends);
        return e;
    }

    /**
     * Parse a datetime-local input value ("2025-12-25T14:30") to a SQL Timestamp.
     * Returns null if the string is blank or malformed.
     */
    private Timestamp parseDateTime(String input) {
        if (input == null || input.isBlank()) return null;
        try {
            // datetime-local format: "yyyy-MM-ddTHH:mm" — add :00 for seconds
            String normalized = input.trim().replace("T", " ");
            if (normalized.length() == 16) normalized += ":00";
            return Timestamp.valueOf(normalized);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    /**
     * Save an uploaded image file to ~/vms_uploads/events/.
     * Returns the DB path "uploads/events/filename.ext", or null if nothing was uploaded.
     */
    private String saveUploadedImage(HttpServletRequest request, String fieldName) {
        try {
            Part part = request.getPart(fieldName);
            if (part == null || part.getSize() == 0) return null;

            String contentType = part.getContentType();
            if (!isAllowedImageType(contentType)) return null;

            String uploadDir = System.getProperty("user.home")
                    + File.separator + "vms_uploads"
                    + File.separator + "events";

            File folder = new File(uploadDir);
            if (!folder.exists()) folder.mkdirs();

            String ext      = extensionFor(contentType);
            String fileName = UUID.randomUUID().toString().replace("-", "").substring(0, 12) + ext;
            String filePath = uploadDir + File.separator + fileName;

            try (InputStream in = part.getInputStream()) {
                Files.copy(in, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
            }
            return "uploads/events/" + fileName;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private boolean isAllowedImageType(String ct) {
        if (ct == null) return false;
        for (String allowed : ALLOWED_IMG) {
            if (allowed.equalsIgnoreCase(ct)) return true;
        }
        return false;
    }

    private String extensionFor(String ct) {
        switch (ct.toLowerCase()) {
            case "image/png":  return ".png";
            case "image/gif":  return ".gif";
            case "image/webp": return ".webp";
            default:           return ".jpg";
        }
    }

    private String getParam(HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        return val != null ? val.trim() : "";
    }

    /** Guard: redirect non-admins away and return false. */
    private boolean isAdmin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            res.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }
}

package com.VMS.controller;

import com.VMS.dao.ProfileDAO;
import com.VMS.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.util.UUID;

/**
 * ProfileController
 *
 * Routes:
 *   GET  /volunteer/profile  → show profile page (pre-filled)
 *   POST /volunteer/profile  → save profile changes
 *   GET  /admin/profile      → show profile page (pre-filled)
 *   POST /admin/profile      → save profile changes
 */
@WebServlet({"/volunteer/profile", "/admin/profile"})
@MultipartConfig(
    maxFileSize    = 2 * 1024 * 1024,   // 2 MB per file
    maxRequestSize = 5 * 1024 * 1024    // 5 MB total request
)
public class ProfileController extends HttpServlet {

    private final ProfileDAO profileDao = new ProfileDAO();

    // Allowed image types
    private static final String[] ALLOWED_TYPES = {"image/jpeg", "image/png", "image/gif", "image/webp"};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        User   user   = profileDao.getUserById(userId);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("user", user);
        forwardToProfile(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String userId = (String) session.getAttribute("userId");

        // ── Read text fields ──
        String firstName = getParam(request, "firstName");
        String lastName  = getParam(request, "lastName");
        String email     = getParam(request, "email");
        String username  = getParam(request, "username");
        String phone     = getParam(request, "phone");
        String bio       = getParam(request, "bio");

        // ── Validation ──
        if (firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || username.isEmpty()) {
            User user = profileDao.getUserById(userId);
            request.setAttribute("user", user);
            request.setAttribute("error", "First name, last name, email and username are required.");
            forwardToProfile(request, response);
            return;
        }

        if (profileDao.isEmailTakenByOther(email, userId)) {
            User user = profileDao.getUserById(userId);
            request.setAttribute("user", user);
            request.setAttribute("error", "That email is already used by another account.");
            forwardToProfile(request, response);
            return;
        }

        if (profileDao.isUsernameTakenByOther(username, userId)) {
            User user = profileDao.getUserById(userId);
            request.setAttribute("user", user);
            request.setAttribute("error", "That username is already taken.");
            forwardToProfile(request, response);
            return;
        }

        // ── Handle profile photo upload ──
        Part photoPart = request.getPart("profilePhoto");
        if (photoPart != null && photoPart.getSize() > 0) {
            String contentType = photoPart.getContentType();

            // Validate file type
            if (!isAllowedType(contentType)) {
                User user = profileDao.getUserById(userId);
                request.setAttribute("user", user);
                request.setAttribute("error", "Invalid image type. Please upload JPG, PNG, GIF or WEBP.");
                forwardToProfile(request, response);
                return;
            }

            // Save to a permanent directory outside the deploy folder so
            // files survive Eclipse republishes.
            String uploadDir = System.getProperty("user.home") + File.separator
                             + "vms_uploads" + File.separator + "profiles";
            Files.createDirectories(Paths.get(uploadDir));

            // Generate unique filename to avoid conflicts
            String extension = getExtension(contentType);
            String fileName  = userId + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
            String filePath  = uploadDir + File.separator + fileName;

            // Save file to disk
            try (InputStream input = photoPart.getInputStream()) {
                Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
            }

            // Save relative path to DB (used in <img src="...">)
            String dbPath = "uploads/profiles/" + fileName;
            profileDao.updateProfilePhoto(userId, dbPath);
        }

        // ── Save text fields to DB ──
        boolean updated = profileDao.updateProfile(userId, firstName, lastName, email, username, phone, bio);

        // ── Update session username if changed ──
        session.setAttribute("userName", username);

        // ── Redirect back with result ──
        String role = (String) session.getAttribute("userRole");
        String base = "admin".equals(role) ? "/admin/profile" : "/volunteer/profile";

     
        if (updated) {
            response.sendRedirect(request.getContextPath() + base + "?success=Profile+updated+successfully");
        } else {
            response.sendRedirect(request.getContextPath() + base + "?error=Failed+to+update+profile.+Please+try+again.");
        }
    }

    // ── Helpers ──

    private void forwardToProfile(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String role = (String) req.getSession().getAttribute("userRole");
        String jsp  = "admin".equals(role)
            ? "/WEB-INF/pages/admin/profile.jsp"
            : "/WEB-INF/pages/volunteer/profile.jsp";
        req.getRequestDispatcher(jsp).forward(req, res);
    }

    private String getParam(HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        return val != null ? val.trim() : "";
    }

    private boolean isAllowedType(String contentType) {
        if (contentType == null) return false;
        for (String t : ALLOWED_TYPES) {
            if (t.equalsIgnoreCase(contentType)) return true;
        }
        return false;
    }

    private String getExtension(String contentType) {
        switch (contentType.toLowerCase()) {
            case "image/png":  return ".png";
            case "image/gif":  return ".gif";
            case "image/webp": return ".webp";
            default:           return ".jpg";
        }
    }
}
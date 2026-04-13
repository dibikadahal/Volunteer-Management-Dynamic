package com.VMS.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;

/**
 * Serves uploaded files (profile photos) from the permanent
 * storage directory outside the Tomcat deploy folder.
 *
 * URL pattern: /uploads/*
 * Example: GET /VolunteerManagement/uploads/profiles/userId_abc.jpg
 *   → reads from: user.home/vms_uploads/profiles/userId_abc.jpg
 */
@WebServlet("/uploads/*")
public class FileServlet extends HttpServlet {

    private static final String UPLOAD_ROOT =
        System.getProperty("user.home") + File.separator + "vms_uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // e.g. /profiles/userId_abc.jpg
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Prevent path traversal attacks
        Path filePath = Paths.get(UPLOAD_ROOT + pathInfo).normalize();
        if (!filePath.startsWith(Paths.get(UPLOAD_ROOT).normalize())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        File file = filePath.toFile();
        if (!file.exists() || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Set Content-Type based on extension
        String contentType = getServletContext().getMimeType(file.getName());
        if (contentType == null) contentType = "application/octet-stream";
        response.setContentType(contentType);
        response.setContentLengthLong(file.length());

        // Stream the file
        try (InputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buf = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buf)) != -1) {
                out.write(buf, 0, bytesRead);
            }
        }
    }
}

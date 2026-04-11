package com.VMS.controller;

import com.VMS.dao.PasswordResetDAO;
import com.VMS.util.EmailService;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;

/**
 * PasswordResetController
 *
 * Routes handled:
 *   GET  /forgot-password  → show forgot password page
 *   POST /forgot-password  → process email, send reset link
 *   GET  /reset-password   → show reset password form (validates token)
 *   POST /reset-password   → process new password, update DB
 */
@WebServlet({"/forgot-password", "/reset-password"})
public class PasswordResetController extends HttpServlet {

    private final PasswordResetDAO resetDao = new PasswordResetDAO();

    // ── Base URL of your app — change port/context if needed ──
    private static final String BASE_URL = "http://localhost:8081/VolunteerManagement";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if (path.equals("/forgot-password")) {
            // Show the forgot password page
            request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
                   .forward(request, response);

        } else if (path.equals("/reset-password")) {
            // Validate the token from the URL
            String token = request.getParameter("token");

            if (token == null || token.isEmpty()) {
                request.setAttribute("error", "Invalid or missing reset link.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
                       .forward(request, response);
                return;
            }

            String email = resetDao.validateToken(token);

            if (email == null) {
                // Token is invalid or expired
                request.setAttribute("error", "This reset link has expired or is invalid. Please request a new one.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
                       .forward(request, response);
                return;
            }

            // Token is valid — show the reset password form
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp")
                   .forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if (path.equals("/forgot-password")) {
            handleForgotPassword(request, response);
        } else if (path.equals("/reset-password")) {
            handleResetPassword(request, response);
        }
    }

    /**
     * Step 1 — User submits their email.
     * Generate token, save to DB, send reset email.
     */
    private void handleForgotPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Please enter your email address.");
            request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
                   .forward(request, response);
            return;
        }

        email = email.trim().toLowerCase();

        // Always show success message even if email not found (security best practice —
        // prevents email enumeration attacks)
        if (resetDao.emailExists(email)) {
            String token     = resetDao.createResetToken(email);
            String resetLink = BASE_URL + "/reset-password?token=" + token;

            try {
                EmailService.sendPasswordResetEmail(email, resetLink);
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Failed to send email. Please try again later.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
                       .forward(request, response);
                return;
            }
        }

        // Show success regardless of whether email existed
        request.setAttribute("success",
            "If an account exists with that email, a reset link has been sent. Please check your inbox.");
        request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
               .forward(request, response);
    }

    /**
     * Step 2 — User submits new password with token.
     * Validate token, hash password, update DB.
     */
    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token           = request.getParameter("token");
        String newPassword     = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate all fields present
        if (token == null || token.isEmpty() ||
            newPassword == null || newPassword.isEmpty() ||
            confirmPassword == null || confirmPassword.isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp")
                   .forward(request, response);
            return;
        }

        // Re-validate token (might have expired while user was on the page)
        String email = resetDao.validateToken(token);
        if (email == null) {
            request.setAttribute("error", "This reset link has expired. Please request a new one.");
            request.getRequestDispatcher("/WEB-INF/pages/forgot-password.jsp")
                   .forward(request, response);
            return;
        }

        // Check passwords match
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp")
                   .forward(request, response);
            return;
        }

        // Check password length
        if (newPassword.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp")
                   .forward(request, response);
            return;
        }

        // Hash and update
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
        boolean updated = resetDao.updatePassword(token, hashedPassword);

        if (updated) {
            // Redirect to login with success message
            response.sendRedirect(request.getContextPath()
                + "/login?success=Password+reset+successfully.+Please+sign+in+with+your+new+password.");
        } else {
            request.setAttribute("error", "Something went wrong. Please try again.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/pages/reset-password.jsp")
                   .forward(request, response);
        }
    }
}
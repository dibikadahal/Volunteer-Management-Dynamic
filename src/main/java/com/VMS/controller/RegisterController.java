package com.VMS.controller;

import com.VMS.model.User;
import com.VMS.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

// @WebServlet("/OLDregister")
public class RegisterController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserService userService = new UserService();

    // doGet: show the register page
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("WEB-INF/pages/register.jsp")
               .forward(request, response);
    }

    // doPost: handle form submission
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get all form fields
        String firstName       = request.getParameter("firstName").trim();
        String lastName        = request.getParameter("lastName").trim();
        String email           = request.getParameter("email").trim();
        String username        = request.getParameter("username").trim();
        String phone           = request.getParameter("phone").trim();
        String password        = request.getParameter("password").trim();
        String confirmPassword = request.getParameter("confirmPassword").trim();

        // ── Validation ───────────────────────────────────────
        if (firstName.isEmpty() || lastName.isEmpty() ||
            email.isEmpty() || username.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "All required fields must be filled in.");
            request.getRequestDispatcher("WEB-INF/pages/register.jsp")
                   .forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("WEB-INF/pages/register.jsp")
                   .forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters.");
            request.getRequestDispatcher("WEB-INF/pages/register.jsp")
                   .forward(request, response);
            return;
        }

        // ── Build User object ────────────────────────────────
        User user = new User();
        user.setFirstName(firstName);               // ← was missing before
        user.setLastName(lastName);                 // ← was missing before
        user.setEmail(email);
        user.setUsername(username);
        user.setPassword(password);                 // plain text — hashing done in UserService
        user.setPhone(phone.isEmpty() ? null : phone);

        // ── Save to database ─────────────────────────────────
        try {
            boolean success = userService.registerUser(user);

            if (success) {
                response.sendRedirect(request.getContextPath()
                        + "/login?success=Account+created+successfully.+Please+sign+in.");
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher("WEB-INF/pages/register.jsp")
                       .forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();

            if (e.getMessage().contains("Duplicate entry")) {
                if (e.getMessage().contains("user_email_unique")) {
                    request.setAttribute("error", "This email is already registered.");
                } else if (e.getMessage().contains("user_username_unique")) {
                    request.setAttribute("error", "This username is already taken.");
                } else {
                    request.setAttribute("error", "Account already exists.");
                }
            } else {
                request.setAttribute("error", "Database error. Please try again.");
            }

            request.getRequestDispatcher("WEB-INF/pages/register.jsp")
                   .forward(request, response);
        }
    }
}
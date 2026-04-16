package com.VMS.controller;

import java.io.IOException;
import com.VMS.dao.UserDAO;
import com.VMS.dao.UserDAO.LoginException;
import com.VMS.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet({"/login", "/register", "/logout"})
public class AuthController extends HttpServlet {

    private final UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if (path.equals("/login") || path.equals("") || path.equals("/")) {
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp")
                   .forward(request, response);
        } else if (path.equals("/register")) {
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp")
                   .forward(request, response);
        } else if (path.equals("/logout")) {
            handleLogout(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if (path.equals("/login")) {
            handleLogin(request, response);
        } else if (path.equals("/register")) {
            handleRegister(request, response);
        }
    }

    // ══════════════════════════════════════
    // LOGIN — with account lockout handling
    // ══════════════════════════════════════
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        // Basic input validation
        if (email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp")
                   .forward(request, response);
            return;
        }

        try {
            User user = userDao.validateUserByEmail(email.trim(), password);

            if (user != null) {
                // ── SUCCESS ──
                HttpSession session = request.getSession();
                session.setAttribute("userId",   user.getId());
                session.setAttribute("userName", user.getUsername());
                session.setAttribute("userRole", user.getRole());

                // Set cookie
                Cookie userCookie = new Cookie("user_id", user.getId());
                userCookie.setMaxAge(60 * 60 * 24);
                response.addCookie(userCookie);

                // Redirect based on role
                if ("admin".equals(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/volunteer/dashboard");
                }

            } else {
                // User not found in DB
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp")
                       .forward(request, response);
            }

        } catch (LoginException e) {
            // ── LOCKOUT, DEACTIVATED, or PENDING APPROVAL ──
            request.setAttribute("errorType", e.getReason());
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp")
                   .forward(request, response);
        }
    }

    // ════��═════════════════════════════════
    // REGISTER — Now creates entries in both
    // user and volunteer tables
    // ══════════════════════════════════════
    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String firstName       = request.getParameter("firstName");
        String lastName        = request.getParameter("lastName");
        String email           = request.getParameter("email");
        String username        = request.getParameter("username");
        String phone           = request.getParameter("phone");
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String eventId         = request.getParameter("eventId");  // NEW: Event they're registering for

        // Validation
        if (firstName == null || firstName.isEmpty() ||
            lastName  == null || lastName.isEmpty()  ||
            email     == null || email.isEmpty()     ||
            username  == null || username.isEmpty()  ||
            password  == null || password.isEmpty()) {
            request.setAttribute("error", "All required fields must be filled in.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp")
                   .forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp")
                   .forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp")
                   .forward(request, response);
            return;
        }

        if (eventId == null || eventId.isEmpty()) {
            request.setAttribute("error", "Event ID is required.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp")
                   .forward(request, response);
            return;
        }

        User user = new User();
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setUsername(username);
        user.setPassword(password);
        user.setPhone(phone);
        user.setRole("volunteer");
        user.setIsActive(true);

        // NEW: Pass eventId to registerUser
        boolean isRegistered = userDao.registerUser(user, eventId);

        if (isRegistered) {
            response.sendRedirect(request.getContextPath()
                + "/login?success=Registration+successful!+Awaiting+admin+approval");
        } else {
            String errorMsg = "Registration failed.";
            
            if (userDao.emailExists(email)) {
                errorMsg = "This email address is already registered.";
            } else if (userDao.usernameExists(username)) {
                errorMsg = "This username is already taken.";
            }
            
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp")
                   .forward(request, response);
        }
    }

    // ══════════════════════════════════════
    // LOGOUT
    // ══════════════════════════════════════
    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // Clear cookie
        Cookie cookie = new Cookie("user_id", "");
        cookie.setMaxAge(0);
        response.addCookie(cookie);

        response.sendRedirect(request.getContextPath() + "/login");
    }
}
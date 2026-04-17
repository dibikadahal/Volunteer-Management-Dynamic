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
                HttpSession session = request.getSession();
                session.setAttribute("userId",   user.getId());
                session.setAttribute("userName", user.getUsername());
                session.setAttribute("userRole", user.getRole());

                Cookie userCookie = new Cookie("user_id", user.getId());
                userCookie.setMaxAge(60 * 60 * 24);
                response.addCookie(userCookie);

                if ("admin".equals(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/volunteer/dashboard");
                }

            } else {
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp")
                       .forward(request, response);
            }

        } catch (LoginException e) {
            request.setAttribute("errorType", e.getReason());
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp")
                   .forward(request, response);
        }
    }

    // ══════════════════════════════════════
    // REGISTER
    // Creates user with isActive=false.
    // Admin must approve before login.
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

        User user = new User();
        user.setFirstName(firstName.trim());
        user.setLastName(lastName.trim());
        user.setEmail(email.trim());
        user.setUsername(username.trim());
        user.setPassword(password);
        user.setPhone(phone != null ? phone.trim() : null);

        boolean isRegistered = userDao.registerUser(user);

        if (isRegistered) {
            response.sendRedirect(request.getContextPath()
                + "/login?success=Registration+submitted!+Please+wait+for+admin+approval+before+signing+in.");
        } else {
            String errorMsg = "Registration failed. Please try again.";
            if (userDao.emailExists(email.trim())) {
                errorMsg = "This email address is already registered.";
            } else if (userDao.usernameExists(username.trim())) {
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

        Cookie cookie = new Cookie("user_id", "");
        cookie.setMaxAge(0);
        response.addCookie(cookie);

        response.sendRedirect(request.getContextPath() + "/login");
    }
}

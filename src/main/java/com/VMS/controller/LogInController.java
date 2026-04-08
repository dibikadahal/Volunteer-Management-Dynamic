package com.VMS.controller;

import com.VMS.config.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LogInController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // doGet: user visits /login → just show the login page
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("WEB-INF/pages/login.jsp")
               .forward(request, response);
    }

    // doPost: user submits the form → check email + password
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email").trim();
        String password = request.getParameter("password").trim();

        // Basic validation
        if (email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("WEB-INF/pages/login.jsp")
                   .forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "SELECT * FROM user WHERE email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                // Check if account is deactivated
                if (!rs.getBoolean("isActive")) {
                    request.setAttribute("error", "Your account is deactivated. Contact the admin.");
                    request.getRequestDispatcher("WEB-INF/pages/login.jsp")
                           .forward(request, response);
                    return;
                }

                // Check password
                if (rs.getString("password").equals(password)) {

                    HttpSession session = request.getSession();
                    session.setAttribute("userId",   rs.getString("id"));
                    session.setAttribute("userName", rs.getString("username"));
                    session.setAttribute("userRole", rs.getString("role"));

                    // Redirect based on role
                    if ("admin".equals(rs.getString("role"))) {
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/volunteer/dashboard");
                    }

                } else {
                    request.setAttribute("error", "Invalid email or password.");
                    request.getRequestDispatcher("WEB-INF/pages/login.jsp")
                           .forward(request, response);
                }

            } else {
                request.setAttribute("error", "No account found with that email.");
                request.getRequestDispatcher("WEB-INF/pages/login.jsp")
                       .forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error. Please try again.");
            request.getRequestDispatcher("WEB-INF/pages/login.jsp")
                   .forward(request, response);
        }
    }
}
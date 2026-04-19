package com.VMS.controller;

import com.VMS.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/check-field")
public class CheckFieldController extends HttpServlet {

    private final UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String field = request.getParameter("field");
        String value = request.getParameter("value");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (field == null || value == null || value.trim().isEmpty()) {
            response.getWriter().write("{\"available\": true}");
            return;
        }

        boolean taken = false;
        switch (field) {
            case "username": taken = userDao.usernameExists(value.trim()); break;
            case "email":    taken = userDao.emailExists(value.trim());    break;
            case "phone":    taken = userDao.phoneExists(value.trim());    break;
        }

        response.getWriter().write("{\"available\": " + !taken + "}");
    }
}

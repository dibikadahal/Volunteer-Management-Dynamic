package com.VMS.controller;

import com.VMS.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Handles contact form submissions from the About/Contact page.
 * Forwards the message to the admin inbox via EmailService.
 */
@WebServlet("/contact")
public class ContactController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name    = trim(request.getParameter("name"));
        String email   = trim(request.getParameter("email"));
        String subject = trim(request.getParameter("subject"));
        String message = trim(request.getParameter("message"));

        // Basic validation
        if (name.isEmpty() || email.isEmpty() || subject.isEmpty() || message.isEmpty()) {
            response.sendRedirect(request.getContextPath()
                + "/about?contactError=Please+fill+in+all+fields.#contact");
            return;
        }
        if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            response.sendRedirect(request.getContextPath()
                + "/about?contactError=Please+enter+a+valid+email+address.#contact");
            return;
        }

        try {
            EmailService.sendContactEmail(name, email, subject, message);
            response.sendRedirect(request.getContextPath()
                + "/about?contactSuccess=true#contact");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                + "/about?contactError=Failed+to+send+message.+Please+try+again+later.#contact");
        }
    }

    private static String trim(String s) {
        return s != null ? s.trim() : "";
    }
}

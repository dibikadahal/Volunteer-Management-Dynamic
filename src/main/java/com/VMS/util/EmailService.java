package com.VMS.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

/**
 * EmailService — sends HTML emails via Gmail SMTP.
 * Uses App Password (not your real Gmail password).
 * To generate App Password:
 *   Google Account → Security → 2-Step Verification → App Passwords → Generate
 */
public class EmailService {

    // ── CONFIGURE THESE ──────────────────────────────────────
    private static final String SMTP_HOST     = "smtp.gmail.com";
    private static final int    SMTP_PORT     = 587;
    private static final String SENDER_EMAIL  = "dibikadahal@gmail.com";   
    private static final String SENDER_PASS   = "owmmwgorfzzmtgol";
    private static final String SENDER_NAME   = "VolunteerHub";
    // ─────────────────────────────────────────────────────────

    /**
     * Sends a password reset email with a styled HTML body.
     *
     * @param toEmail   recipient email address
     * @param resetLink full reset URL with token
     */
    public static void sendPasswordResetEmail(String toEmail, String resetLink) throws MessagingException, Exception {

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            SMTP_HOST);
        props.put("mail.smtp.port",            String.valueOf(SMTP_PORT));
        props.put("mail.smtp.ssl.trust",       SMTP_HOST);
        props.put("mail.debug",                "true"); // ← shows full SMTP conversation

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASS);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL, SENDER_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Reset Your VolunteerHub Password");
            message.setContent(buildEmailBody(resetLink), "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("=== EMAIL SENT SUCCESSFULLY ===");

        } catch (Exception e) {
            System.out.println("=== EMAIL FAILED ===");
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    /**
     * Builds a styled HTML email body matching the VolunteerHub purple/blue theme.
     */
    private static String buildEmailBody(String resetLink) {
        return "<!DOCTYPE html>" +
            "<html><head><meta charset='UTF-8'>" +
            "<style>" +
            "  body { margin:0; padding:0; background:#0f0c1a; font-family: 'Segoe UI', sans-serif; }" +
            "  .wrapper { max-width:560px; margin:40px auto; background:#1e1836; border-radius:16px; overflow:hidden; border:1px solid rgba(124,92,191,0.2); }" +
            "  .header { background:linear-gradient(135deg,#7c5cbf,#4f8ef7); padding:36px 40px; text-align:center; }" +
            "  .header h1 { color:#fff; margin:0; font-size:24px; font-weight:700; letter-spacing:0.5px; }" +
            "  .header p  { color:rgba(255,255,255,0.8); margin:6px 0 0; font-size:14px; }" +
            "  .body { padding:36px 40px; }" +
            "  .body p { color:#9b93c0; font-size:15px; line-height:1.7; margin:0 0 20px; }" +
            "  .body p.name { color:#f0ecff; font-weight:600; font-size:16px; }" +
            "  .btn-wrap { text-align:center; margin:28px 0; }" +
            "  .btn { display:inline-block; background:linear-gradient(90deg,#7c5cbf,#4f8ef7); color:#fff !important; " +
            "         text-decoration:none; padding:14px 36px; border-radius:10px; font-size:15px; font-weight:700; letter-spacing:0.3px; }" +
            "  .link-box { background:#16112b; border:1px solid rgba(124,92,191,0.2); border-radius:8px; padding:12px 16px; margin:16px 0; word-break:break-all; }" +
            "  .link-box a { color:#4f8ef7; font-size:13px; text-decoration:none; }" +
            "  .warning { background:rgba(245,166,35,0.1); border:1px solid rgba(245,166,35,0.25); border-radius:8px; padding:12px 16px; }" +
            "  .warning p { color:#f5a623; font-size:13px; margin:0; }" +
            "  .footer { border-top:1px solid rgba(124,92,191,0.15); padding:20px 40px; text-align:center; }" +
            "  .footer p { color:#5c5480; font-size:12px; margin:0; }" +
            "</style></head><body>" +
            "<div class='wrapper'>" +
            "  <div class='header'>" +
            "    <h1>&#9825; VolunteerHub</h1>" +
            "    <p>Password Reset Request</p>" +
            "  </div>" +
            "  <div class='body'>" +
            "    <p>Hello,</p>" +
            "    <p>We received a request to reset the password for your VolunteerHub account. " +
            "       Click the button below to set a new password. This link is valid for <strong style='color:#f0ecff;'>30 minutes</strong>.</p>" +
            "    <div class='btn-wrap'>" +
            "      <a href='" + resetLink + "' class='btn'>Reset My Password</a>" +
            "    </div>" +
            "    <p style='font-size:13px;'>If the button doesn't work, copy and paste this link into your browser:</p>" +
            "    <div class='link-box'><a href='" + resetLink + "'>" + resetLink + "</a></div>" +
            "    <div class='warning'>" +
            "      <p>&#9888;&nbsp; If you did not request a password reset, you can safely ignore this email. Your password will not change.</p>" +
            "    </div>" +
            "  </div>" +
            "  <div class='footer'>" +
            "    <p>&copy; 2026 VolunteerHub. All rights reserved.</p>" +
            "  </div>" +
            "</div>" +
            "</body></html>";
    }
}
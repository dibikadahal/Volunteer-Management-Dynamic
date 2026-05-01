package com.VMS.controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * AuthFilter — Central Redirect Management Filter
 *
 * Covers all routes and handles:
 *   1. Unauthenticated access to protected pages  → redirect to /login
 *   2. Wrong role accessing wrong dashboard       → redirect to correct dashboard
 *   3. Already logged-in user visiting /login     → redirect to their dashboard
 *   4. Already logged-in user visiting /register  → redirect to their dashboard
 *   5. Session expiry                             → redirect to /login?expired=true
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest) request;
        HttpServletResponse res  = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String requestURI  = req.getRequestURI();

        // Strip context path to get the relative path
        String path = requestURI.substring(contextPath.length());

        // ── Allow static resources through without any checks ──
        if (isStaticResource(path)) {
            chain.doFilter(request, response);
            return;
        }

        // ── Context root: logged-in → dashboard, otherwise → landing page ──
        if (path.isEmpty() || path.equals("/")) {
            HttpSession rootSession = req.getSession(false);
            if (rootSession != null && rootSession.getAttribute("userId") != null) {
                String role = (String) rootSession.getAttribute("userRole");
                redirectToDashboard(res, contextPath, role);
                return;
            }
            res.sendRedirect(contextPath + "/home");
            return;
        }

        // ── Allow public routes through without any checks ──
        if (isPublicRoute(path)) {
            // But if already logged in and trying to visit login/register → redirect to dashboard
            if (isAuthPage(path)) {
                HttpSession session = req.getSession(false);
                if (session != null && session.getAttribute("userId") != null) {
                    String role = (String) session.getAttribute("userRole");
                    redirectToDashboard(res, contextPath, role);
                    return;
                }
            }
            chain.doFilter(request, response);
            return;
        }

        // ── From here: all routes are protected ──
        HttpSession session = req.getSession(false);

        // ── No session at all → redirect to login ──
        if (session == null) {
            res.sendRedirect(contextPath + "/login?expired=true");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String role   = (String) session.getAttribute("userRole");

        // ── Session exists but userId is missing → session expired ──
        if (userId == null || role == null) {
            session.invalidate();
            res.sendRedirect(contextPath + "/login?expired=true");
            return;
        }

        // ── Role-based access control ──

        // Admin trying to access volunteer area → redirect to admin dashboard
        if (path.startsWith("/volunteer/") && "admin".equals(role)) {
            res.sendRedirect(contextPath + "/admin/dashboard");
            return;
        }

        // Volunteer trying to access admin area → redirect to volunteer dashboard
        if (path.startsWith("/admin/") && "volunteer".equals(role)) {
            res.sendRedirect(contextPath + "/volunteer/dashboard");
            return;
        }

        // ── All checks passed — allow request through ──
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}

    // ══════════════════════════════════════
    // Helper methods
    // ══════════════════════════════════════

    /**
     * Static resources — CSS, JS, images — always allowed through
     */
    private boolean isStaticResource(String path) {
        return path.startsWith("/css/")
            || path.startsWith("/js/")
            || path.startsWith("/images/")
            || path.startsWith("/fonts/")
            || path.endsWith(".css")
            || path.endsWith(".js")
            || path.endsWith(".png")
            || path.endsWith(".jpg")
            || path.endsWith(".jpeg")
            || path.endsWith(".gif")
            || path.endsWith(".ico")
            || path.endsWith(".svg")
            || path.endsWith(".woff")
            || path.endsWith(".woff2");
    }

    /**
     * Public routes — accessible without login
     */
    private boolean isPublicRoute(String path) {
        return path.equals("/login")
            || path.equals("/register")
            || path.equals("/logout")
            || path.equals("/forgot-password")
            || path.equals("/reset-password")
            || path.equals("/home")
            || path.equals("/about")
            || path.equals("/contact");
    }

    /**
     * Auth pages — login and register
     * Logged-in users should not see these
     */
    private boolean isAuthPage(String path) {
        return path.equals("/login") || path.equals("/register");
    }

    /**
     * Redirect to the correct dashboard based on role
     */
    private void redirectToDashboard(HttpServletResponse res, String contextPath, String role)
            throws IOException {
        if ("admin".equals(role)) {
            res.sendRedirect(contextPath + "/admin/dashboard");
        } else {
            res.sendRedirect(contextPath + "/volunteer/dashboard");
        }
    }
}
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VolunteerHub - Login</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
</head>
<body>

    <!-- Animated Background -->
    <div class="background">
        <div class="animated-bg">
            <div class="blob blob-1"></div>
            <div class="blob blob-2"></div>
            <div class="blob blob-3"></div>
            <div class="floating-particle particle-1"></div>
            <div class="floating-particle particle-2"></div>
            <div class="floating-particle particle-3"></div>
            <div class="floating-particle particle-4"></div>
            <div class="floating-particle particle-5"></div>
        </div>
    </div>

    <div class="main-container">

        <!-- ══ LEFT SIDE — Illustration ══ -->
        <div class="illustration-side">
            <div class="illustration-wrapper">
                <img src="${pageContext.request.contextPath}/images/Volunteers_login1.jpg" alt="Volunteers" class="illustration-img">
                <div class="illustration-overlay">
                    <div class="glow-effect"></div>
                </div>
            </div>
            <div class="side-content">
                <h2 class="side-title">Join Our Community</h2>
                <p class="side-subtitle">Make a difference. Help others. Be part of something meaningful.</p>
                <div class="stat-boxes">
                    <div class="stat-box">
                        <span class="stat-number">${activeVolunteers}+</span>
                        <span class="stat-label">Active Volunteers</span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-number">${totalEvents}+</span>
                        <span class="stat-label">Events</span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-number">${totalAttended}+</span>
                        <span class="stat-label">Attendances</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- ══ RIGHT SIDE — Login Form ══ -->
        <div class="login-side">
            <div class="form-wrapper">

                <!-- Logo -->
                <div class="logo-container">
                    <div class="logo-icon">&#9825;</div>
                    <h1 class="logo-text">VolunteerHub</h1>
                </div>

                <!-- Welcome -->
                <div class="welcome-section">
                    <h2 class="welcome-title">Welcome Back!</h2>
                    <p class="welcome-description">Sign in to continue your journey of making impact</p>
                </div>

                <!-- ══ MESSAGES — all inside the card ══ -->

                <%-- Session expired --%>
                <% if ("true".equals(request.getParameter("expired"))) { %>
                <div class="alert alert-warning">
                    &#9201; Your session has expired. Please sign in again.
                </div>
                <% } %>

                <%-- Success (after registration or password reset) --%>
                <% if (request.getParameter("success") != null) { %>
                <div class="alert alert-success">
                    &#10003; <%= request.getParameter("success") %>
                </div>
                <% } %>

                <%-- Error (wrong password / locked / deactivated) --%>
                <% if (request.getAttribute("error") != null) { %>
                <%
                    String errorType  = (String) request.getAttribute("errorType");
                    String alertClass = "LOCKED".equals(errorType) ? "alert-locked" : "alert-error";
                %>
                <div class="alert <%= alertClass %>">
                    <%= request.getAttribute("error") %>
                </div>
                <% } %>

                <!-- ══ LOGIN FORM ══ -->
                <form action="<%= request.getContextPath() %>/login" method="POST" class="login-form" id="loginForm">

                    <!-- Email -->
                    <div class="form-group">
                        <label for="email" class="form-label">Email Address</label>
                        <div class="form-input-wrapper">
                            <span class="input-icon">&#9993;</span>
                            <input type="text" id="email" name="email"
                                   placeholder="Enter your email"
                                   class="form-input">
                            <span class="input-validation" id="emailStatus"></span>
                        </div>
                        <span class="field-error" id="emailError"></span>
                    </div>

                    <!-- Password -->
                    <div class="form-group">
                        <div class="label-row">
                            <label for="password" class="form-label">Password</label>
                            <a href="${pageContext.request.contextPath}/forgot-password" class="forgot-link">Forgot?</a>
                        </div>
                        <div class="form-input-wrapper">
                            <span class="input-icon">&#128274;</span>
                            <input type="password" id="password" name="password"
                                   placeholder="Enter your password"
                                   class="form-input">
                            <button type="button" class="password-toggle" onclick="togglePassword()">
                                <span class="toggle-icon">&#128065;&#65039;</span>
                            </button>
                        </div>
                        <span class="field-error" id="passwordError"></span>
                    </div>

                    <!-- Remember Me -->
                    <label class="checkbox-label">
                        <input type="checkbox" name="remember" class="checkbox-input">
                        <span class="checkbox-custom"></span>
                        <span class="checkbox-text">Keep me signed in</span>
                    </label>

                    <!-- Submit -->
                    <button type="submit" class="login-button">
                        <span class="button-content">
                            <span class="button-text">Sign In</span>
                            <span class="button-icon">&#8594;</span>
                        </span>
                        <span class="button-shimmer"></span>
                    </button>

                </form>

                <!-- Divider -->
                <div class="divider">
                    <span class="divider-line"></span>
                    <span class="divider-text">or continue with</span>
                    <span class="divider-line"></span>
                </div>

                <!-- Social Buttons -->
                <div class="social-buttons">
                    <button type="button" class="social-btn google-btn" title="Google">
                        <svg viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="currentColor"/></svg>
                    </button>
                    <button type="button" class="social-btn facebook-btn" title="Facebook">
                        <svg viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" fill="currentColor"/></svg>
                    </button>
                    <button type="button" class="social-btn linkedin-btn" title="LinkedIn">
                        <svg viewBox="0 0 24 24"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.225 0z" fill="currentColor"/></svg>
                    </button>
                </div>

                <!-- Sign Up Link -->
                <div class="signup-prompt">
                    <span class="signup-text">New volunteer?</span>
                    <a href="<%= request.getContextPath() %>/register" class="signup-link">Create Account</a>
                </div>

            </div>

            <!-- Footer -->
            <div class="login-footer">
                <p class="footer-text">&#169; 2026 VolunteerHub. All rights reserved.</p>
                <div class="footer-links">
                    <a href="#privacy">Privacy Policy</a>
                    <a href="#terms">Terms of Service</a>
                </div>
            </div>
        </div>

    </div><!-- end main-container -->

    <script>
        function togglePassword() {
            const passwordInput = document.getElementById('password');
            const toggleBtn = document.querySelector('.password-toggle');
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                toggleBtn.innerHTML = '<span class="toggle-icon">&#128584;</span>';
            } else {
                passwordInput.type = 'password';
                toggleBtn.innerHTML = '<span class="toggle-icon">&#128065;&#65039;</span>';
            }
        }

        function showError(id, msg) {
            const el = document.getElementById(id);
            if (!el) return;
            el.textContent = msg;
            el.style.display = msg ? 'block' : 'none';
        }

        function isValidEmail(val) {
            return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val);
        }

        document.querySelectorAll('.form-input').forEach(input => {
            input.addEventListener('focus', function() {
                this.parentElement.classList.add('focused');
            });
            input.addEventListener('blur', function() {
                this.parentElement.classList.remove('focused');
                if (this.value) this.parentElement.classList.add('filled');
                else this.parentElement.classList.remove('filled');
            });
            input.addEventListener('input', function() {
                if (this.value) this.parentElement.classList.add('filled');
                else this.parentElement.classList.remove('filled');
            });
        });

        // Clear errors on input
        document.getElementById('email').addEventListener('input', function() {
            showError('emailError', '');
        });
        document.getElementById('password').addEventListener('input', function() {
            showError('passwordError', '');
        });

        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const email    = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;
            let valid = true;

            if (!email) {
                showError('emailError', 'Email address is required.');
                valid = false;
            } else if (!isValidEmail(email)) {
                showError('emailError', 'Please enter a valid email address (e.g. user@example.com).');
                valid = false;
            } else {
                showError('emailError', '');
            }

            if (!password) {
                showError('passwordError', 'Password is required.');
                valid = false;
            } else {
                showError('passwordError', '');
            }

            if (!valid) return;

            const button = this.querySelector('.login-button');
            button.classList.add('loading');
            setTimeout(() => {
                button.classList.remove('loading');
                this.submit();
            }, 1500);
        });
    </script>

</body>
</html>
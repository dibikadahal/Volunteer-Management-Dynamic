<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VolunteerHub - Login</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
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
                    <div class="logo-icon"><i class="fas fa-heart"></i></div>
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
                    <i class="fas fa-clock"></i> Your session has expired. Please sign in again.
                </div>
                <% } %>

                <%-- Success (after registration or password reset) --%>
                <% if (request.getParameter("success") != null) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <%= request.getParameter("success") %>
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
                            <span class="input-icon"><i class="fas fa-envelope"></i></span>
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
                            <span class="input-icon"><i class="fas fa-lock"></i></span>
                            <input type="password" id="password" name="password"
                                   placeholder="Enter your password"
                                   class="form-input">
                            <button type="button" class="password-toggle" onclick="togglePassword()">
                                <i id="pwToggleIcon" class="fas fa-eye"></i>
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
                            <span class="button-icon"><i class="fas fa-arrow-right"></i></span>
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
                        <i class="fab fa-google"></i>
                    </button>
                    <button type="button" class="social-btn facebook-btn" title="Facebook">
                        <i class="fab fa-facebook-f"></i>
                    </button>
                    <button type="button" class="social-btn linkedin-btn" title="LinkedIn">
                        <i class="fab fa-linkedin-in"></i>
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
                <p class="footer-text">&copy; 2026 VolunteerHub. All rights reserved.</p>
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
            const icon = document.getElementById('pwToggleIcon');
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                icon.className = 'fas fa-eye-slash';
            } else {
                passwordInput.type = 'password';
                icon.className = 'fas fa-eye';
            }
        }

        function showError(id, msg) {
            const el = document.getElementById(id);
            if (!el) return;
            el.textContent = msg;
            el.style.display = msg ? 'block' : 'none';
            el.style.color = '#EF4444';
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
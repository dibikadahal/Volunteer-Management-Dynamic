<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VolunteerHub - Create Account</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/register.css">
</head>
<body>
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
        <!-- Left side - Illustration/Info -->
        <div class="illustration-side">
            <div class="illustration-wrapper">
                <img src="${pageContext.request.contextPath}/images/Volunteers_login.jpg" alt="Volunteers" class="illustration-img">
                <div class="illustration-overlay">
                    <div class="glow-effect"></div>
                </div>
            </div>
            <div class="side-content">
                <h2 class="side-title">Start Your Journey</h2>
                <p class="side-subtitle">Join thousands of volunteers making a real difference in the world.</p>
                <div class="benefit-items">
                    <div class="benefit-item">
                        <span class="benefit-icon">✓</span>
                        <span class="benefit-text">Find meaningful projects</span>
                    </div>
                    <div class="benefit-item">
                        <span class="benefit-icon">✓</span>
                        <span class="benefit-text">Connect with like-minded people</span>
                    </div>
                    <div class="benefit-item">
                        <span class="benefit-icon">✓</span>
                        <span class="benefit-text">Track your impact</span>
                    </div>
                    <div class="benefit-item">
                        <span class="benefit-icon">✓</span>
                        <span class="benefit-text">Grow your skills</span>
                    </div>
                </div>
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

        <!-- Right side - Registration Form -->
        <div class="register-side">
            <div class="form-wrapper">
                <!-- Logo -->
                <div class="logo-container">
                    <div class="logo-icon">♡</div>
                    <h1 class="logo-text">VolunteerHub</h1>
                </div>

                <!-- Welcome Section -->
                <div class="welcome-section">
                    <h2 class="welcome-title">Create Account</h2>
                    <p class="welcome-description">Join our community of volunteers</p>
                </div>

                <!-- Server-side error banner -->
                <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error" id="serverError">
                    <span class="alert-icon">⚠</span>
                    <%= request.getAttribute("error") %>
                </div>
                <% } %>

                <!-- Registration Form -->
                <form action="${pageContext.request.contextPath}/register" method="POST" class="register-form" id="registerForm" novalidate>
                    <!-- Name Row -->
                    <div class="form-row">
                        <div class="form-group half">
                            <label for="firstName" class="form-label">First Name</label>
                            <div class="form-input-wrapper">
                                <span class="input-icon">👤</span>
                                <input
                                    type="text"
                                    id="firstName"
                                    name="firstName"
                                    placeholder="John"
                                    class="form-input"
                                >
                            </div>
                            <span class="field-error" id="firstNameError"></span>
                        </div>

                        <div class="form-group half">
                            <label for="lastName" class="form-label">Last Name</label>
                            <div class="form-input-wrapper">
                                <span class="input-icon">👤</span>
                                <input
                                    type="text"
                                    id="lastName"
                                    name="lastName"
                                    placeholder="Doe"
                                    class="form-input"
                                >
                            </div>
                            <span class="field-error" id="lastNameError"></span>
                        </div>
                    </div>

                    <!-- Email Input -->
                    <div class="form-group">
                        <label for="email" class="form-label">Email Address</label>
                        <div class="form-input-wrapper">
                            <span class="input-icon">✉</span>
                            <input
                                type="email"
                                id="email"
                                name="email"
                                placeholder="volunteer@example.com"
                                class="form-input"
                            >
                            <span class="input-validation" id="emailStatus"></span>
                        </div>
                        <span class="field-error" id="emailError"></span>
                    </div>

                    <!-- Username Input -->
                    <div class="form-group">
                        <label for="username" class="form-label">Username</label>
                        <div class="form-input-wrapper">
                            <span class="input-icon">@</span>
                            <input
                                type="text"
                                id="username"
                                name="username"
                                placeholder="volunteer_name"
                                class="form-input"
                            >
                            <span class="input-validation" id="usernameStatus"></span>
                        </div>
                        <span class="field-error" id="usernameError"></span>
                    </div>

                    <!-- Phone Input -->
                    <div class="form-group">
                        <label for="phone" class="form-label">Phone Number</label>
                        <div class="form-input-wrapper">
                            <span class="input-icon">📱</span>
                            <input
                                type="tel"
                                id="phone"
                                name="phone"
                                placeholder="+1 (555) 000-0000"
                                class="form-input"
                            >
                            <span class="input-validation" id="phoneStatus"></span>
                        </div>
                        <span class="field-error" id="phoneError"></span>
                    </div>

                    <!-- Password Input -->
                    <div class="form-group">
                        <label for="password" class="form-label">Password</label>
                        <div class="form-input-wrapper">
                            <span class="input-icon">🔒</span>
                            <input
                                type="password"
                                id="password"
                                name="password"
                                placeholder="••••••••••••"
                                class="form-input"
                            >
                            <button type="button" class="password-toggle" onclick="togglePassword()">
                                <span class="toggle-icon">👁️</span>
                            </button>
                        </div>
                        <div class="password-strength">
                            <div class="strength-bar"></div>
                            <span class="strength-text">Password strength</span>
                        </div>
                        <span class="field-error" id="passwordError"></span>
                    </div>

                    <!-- Confirm Password Input -->
                    <div class="form-group">
                        <label for="confirmPassword" class="form-label">Confirm Password</label>
                        <div class="form-input-wrapper">
                            <span class="input-icon">🔒</span>
                            <input
                                type="password"
                                id="confirmPassword"
                                name="confirmPassword"
                                placeholder="••••••••••••"
                                class="form-input"
                            >
                            <button type="button" class="password-toggle" onclick="toggleConfirmPassword()">
                                <span class="toggle-icon">👁️</span>
                            </button>
                        </div>
                        <span class="field-error" id="confirmPasswordError"></span>
                    </div>

                    <!-- Terms & Privacy -->
                    <label class="checkbox-label">
                        <input type="checkbox" name="terms" id="terms" class="checkbox-input">
                        <span class="checkbox-custom"></span>
                        <span class="checkbox-text">
                            I agree to the <a href="#terms" class="link">Terms of Service</a> and <a href="#privacy" class="link">Privacy Policy</a>
                        </span>
                    </label>
                    <span class="field-error" id="termsError"></span>

                    <!-- Register Button -->
                    <button type="submit" class="register-button" id="submitBtn">
                        <span class="button-content">
                            <span class="button-text">Create Account</span>
                            <span class="button-icon">→</span>
                        </span>
                        <span class="button-shimmer"></span>
                    </button>
                </form>

                <!-- Divider -->
                <div class="divider">
                    <span class="divider-line"></span>
                    <span class="divider-text">or register with</span>
                    <span class="divider-line"></span>
                </div>

                <!-- Social Login -->
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

                <!-- Sign In Link -->
                <div class="signin-prompt">
                    <span class="signin-text">Already have an account?</span>
                    <a href="${pageContext.request.contextPath}/login" class="signin-link">Sign In</a>
                </div>
            </div>

            <!-- Footer in Register Section -->
            <div class="register-footer">
                <p class="footer-text">© 2026 VolunteerHub. All rights reserved.</p>
            </div>
        </div>
    </div>
    
    <script>
    const CTX = '${pageContext.request.contextPath}';

    // ── Helpers ──────────────────────────────────────
    function showError(id, msg) {
        const el = document.getElementById(id);
        if (el) { el.textContent = msg; el.style.display = msg ? 'block' : 'none'; }
    }
    function setStatus(id, ok) {
        const el = document.getElementById(id);
        if (!el) return;
        el.textContent = ok === null ? '' : (ok ? '✓' : '✗');
        el.style.color  = ok === null ? '' : (ok ? '#10B981' : '#EF4444');
    }

    // ── Eye toggles ──────────────────────────────────
    function togglePassword() {
        const input = document.getElementById('password');
        const btn   = document.querySelector('#password ~ .password-toggle .toggle-icon');
        input.type  = input.type === 'password' ? 'text' : 'password';
        btn.textContent = input.type === 'password' ? '👁️' : '🙈';
    }
    function toggleConfirmPassword() {
        const input = document.getElementById('confirmPassword');
        const btn   = document.querySelector('#confirmPassword ~ .password-toggle .toggle-icon');
        input.type  = input.type === 'password' ? 'text' : 'password';
        btn.textContent = input.type === 'password' ? '👁️' : '🙈';
    }

    // ── Debounce helper ──────────────────────────────
    function debounce(fn, ms) {
        let t;
        return function(...args) { clearTimeout(t); t = setTimeout(() => fn.apply(this, args), ms); };
    }

    // ── AJAX availability check ──────────────────────
    function checkField(field, value, statusId, errorId, takenMsg) {
        if (!value.trim()) { setStatus(statusId, null); showError(errorId, ''); return; }
        fetch(CTX + '/check-field?field=' + field + '&value=' + encodeURIComponent(value))
            .then(r => r.json())
            .then(data => {
                if (data.available) {
                    setStatus(statusId, true);
                    showError(errorId, '');
                } else {
                    setStatus(statusId, false);
                    showError(errorId, takenMsg);
                }
            });
    }

    // ── Real-time field checks ────────────────────────
    document.getElementById('username').addEventListener('input', debounce(function () {
        checkField('username', this.value, 'usernameStatus', 'usernameError', 'Username is already taken.');
    }, 400));

    document.getElementById('email').addEventListener('input', debounce(function () {
        checkField('email', this.value, 'emailStatus', 'emailError', 'Email is already registered.');
    }, 400));

    document.getElementById('phone').addEventListener('input', debounce(function () {
        const val = this.value.trim();
        if (val) checkField('phone', val, 'phoneStatus', 'phoneError', 'Phone number is already registered.');
        else { setStatus('phoneStatus', null); showError('phoneError', ''); }
    }, 400));

    // ── Password validation ───────────────────────────
    document.getElementById('password').addEventListener('input', function () {
        const val  = this.value;
        const bar  = document.querySelector('.strength-bar');
        const text = document.querySelector('.strength-text');

        let strength = 0;
        if (val.length >= 6)           strength++;
        if (val.length >= 10)          strength++;
        if (/[A-Z]/.test(val))         strength++;
        if (/[0-9]/.test(val))         strength++;
        if (/[^A-Za-z0-9]/.test(val)) strength++;

        const levels = [
            { width: '0%',   color: '#E5E7EB', label: 'Password strength' },
            { width: '20%',  color: '#EF4444', label: 'Very weak' },
            { width: '40%',  color: '#F59E0B', label: 'Weak' },
            { width: '60%',  color: '#EAB308', label: 'Fair' },
            { width: '80%',  color: '#10B981', label: 'Strong' },
            { width: '100%', color: '#059669', label: 'Very strong' },
        ];
        const level = levels[strength];
        bar.style.setProperty('--strength-width', level.width);
        bar.style.setProperty('--strength-color', level.color);
        text.textContent = level.label;
        text.style.color = level.color;

        // Inline password rule feedback
        let msg = '';
        if (val && val.length < 6)               msg = 'Password must be at least 6 characters.';
        else if (val && !/[0-9]/.test(val))      msg = 'Password must contain at least one number.';
        else if (val && !/[^A-Za-z0-9]/.test(val)) msg = 'Password must contain at least one special character.';
        showError('passwordError', msg);

        // Re-validate confirm field if already typed
        const confirm = document.getElementById('confirmPassword').value;
        if (confirm) validateConfirm();
    });

    function validateConfirm() {
        const p = document.getElementById('password').value;
        const c = document.getElementById('confirmPassword').value;
        showError('confirmPasswordError', c && p !== c ? 'Passwords do not match.' : '');
    }
    document.getElementById('confirmPassword').addEventListener('input', validateConfirm);

    // ── Submit validation ─────────────────────────────
    document.getElementById('registerForm').addEventListener('submit', function (e) {
        let valid = true;

        const firstName = document.getElementById('firstName').value.trim();
        const lastName  = document.getElementById('lastName').value.trim();
        const email     = document.getElementById('email').value.trim();
        const username  = document.getElementById('username').value.trim();
        const password  = document.getElementById('password').value;
        const confirm   = document.getElementById('confirmPassword').value;
        const terms     = document.getElementById('terms').checked;

        if (!firstName) { showError('firstNameError', 'First name is required.'); valid = false; }
        else showError('firstNameError', '');

        if (!lastName) { showError('lastNameError', 'Last name is required.'); valid = false; }
        else showError('lastNameError', '');

        if (!email) { showError('emailError', 'Email is required.'); valid = false; }

        if (!username) { showError('usernameError', 'Username is required.'); valid = false; }

        if (!password) {
            showError('passwordError', 'Password is required.'); valid = false;
        } else if (password.length < 6) {
            showError('passwordError', 'Password must be at least 6 characters.'); valid = false;
        } else if (!/[0-9]/.test(password)) {
            showError('passwordError', 'Password must contain at least one number.'); valid = false;
        } else if (!/[^A-Za-z0-9]/.test(password)) {
            showError('passwordError', 'Password must contain at least one special character.'); valid = false;
        }

        if (password && confirm && password !== confirm) {
            showError('confirmPasswordError', 'Passwords do not match.'); valid = false;
        } else if (!confirm) {
            showError('confirmPasswordError', 'Please confirm your password.'); valid = false;
        }

        if (!terms) { showError('termsError', 'You must accept the terms to register.'); valid = false; }
        else showError('termsError', '');

        // Block if any inline duplicate error is visible
        const usernameErr = document.getElementById('usernameError').textContent;
        const emailErr    = document.getElementById('emailError').textContent;
        const phoneErr    = document.getElementById('phoneError').textContent;
        if (usernameErr || emailErr || phoneErr) valid = false;

        if (!valid) e.preventDefault();
    });
</script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VolunteerHub - Create Account</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
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
                        <span class="benefit-icon"><i class="fas fa-check"></i></span>
                        <span class="benefit-text">Find meaningful projects</span>
                    </div>
                    <div class="benefit-item">
                        <span class="benefit-icon"><i class="fas fa-check"></i></span>
                        <span class="benefit-text">Connect with like-minded people</span>
                    </div>
                    <div class="benefit-item">
                        <span class="benefit-icon"><i class="fas fa-check"></i></span>
                        <span class="benefit-text">Track your impact</span>
                    </div>
                    <div class="benefit-item">
                        <span class="benefit-icon"><i class="fas fa-check"></i></span>
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
                    <div class="logo-icon"><i class="fas fa-heart"></i></div>
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
                    <i class="fas fa-exclamation-triangle alert-icon"></i>
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
                                <span class="input-icon"><i class="fas fa-user"></i></span>
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
                                <span class="input-icon"><i class="fas fa-user"></i></span>
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
                            <span class="input-icon"><i class="fas fa-envelope"></i></span>
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
                            <span class="input-icon"><i class="fas fa-at"></i></span>
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
                            <span class="input-icon"><i class="fas fa-phone"></i></span>
                            <input
                                type="tel"
                                id="phone"
                                name="phone"
                                placeholder="10-digit phone number"
                                class="form-input"
                                maxlength="15"
                            >
                            <span class="input-validation" id="phoneStatus"></span>
                        </div>
                        <span class="field-error" id="phoneError"></span>
                    </div>

                    <!-- Password Input -->
                    <div class="form-group">
                        <label for="password" class="form-label">Password</label>
                        <div class="form-input-wrapper">
                            <span class="input-icon"><i class="fas fa-lock"></i></span>
                            <input
                                type="password"
                                id="password"
                                name="password"
                                placeholder="••••••••••••"
                                class="form-input"
                            >
                            <button type="button" class="password-toggle" onclick="togglePassword()">
                                <i id="pwToggleIcon" class="fas fa-eye"></i>
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
                            <span class="input-icon"><i class="fas fa-lock"></i></span>
                            <input
                                type="password"
                                id="confirmPassword"
                                name="confirmPassword"
                                placeholder="••••••••••••"
                                class="form-input"
                            >
                            <button type="button" class="password-toggle" onclick="toggleConfirmPassword()">
                                <i id="cpToggleIcon" class="fas fa-eye"></i>
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
                            <span class="button-icon"><i class="fas fa-arrow-right"></i></span>
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
                        <i class="fab fa-google"></i>
                    </button>
                    <button type="button" class="social-btn facebook-btn" title="Facebook">
                        <i class="fab fa-facebook-f"></i>
                    </button>
                    <button type="button" class="social-btn linkedin-btn" title="LinkedIn">
                        <i class="fab fa-linkedin-in"></i>
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
        if (el) {
            el.textContent = msg;
            el.style.display = msg ? 'block' : 'none';
            el.style.color = '#EF4444';
        }
    }
    function setStatus(id, ok) {
        const el = document.getElementById(id);
        if (!el) return;
        if (ok === null) {
            el.innerHTML = '';
            el.style.opacity = '0';
        } else if (ok) {
            el.innerHTML = '<i class="fas fa-check"></i>';
            el.style.color = '#10B981';
            el.style.opacity = '1';
        } else {
            el.innerHTML = '<i class="fas fa-times"></i>';
            el.style.color = '#EF4444';
            el.style.opacity = '1';
        }
    }

    // ── Eye toggles ──────────────────────────────────
    function togglePassword() {
        const input = document.getElementById('password');
        const icon  = document.getElementById('pwToggleIcon');
        input.type  = input.type === 'password' ? 'text' : 'password';
        icon.className = input.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash';
    }
    function toggleConfirmPassword() {
        const input = document.getElementById('confirmPassword');
        const icon  = document.getElementById('cpToggleIcon');
        input.type  = input.type === 'password' ? 'text' : 'password';
        icon.className = input.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash';
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
        if (!val) { setStatus('phoneStatus', null); showError('phoneError', 'Phone number is required.'); return; }
        const digits = val.replace(/\D/g, '');
        if (digits.length !== 10) {
            setStatus('phoneStatus', false);
            showError('phoneError', 'Phone number must be exactly 10 digits.');
            return;
        }
        checkField('phone', val, 'phoneStatus', 'phoneError', 'Phone number is already registered.');
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
    function isValidEmail(val) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val);
    }

    document.getElementById('registerForm').addEventListener('submit', function (e) {
        let valid = true;

        const firstName = document.getElementById('firstName').value.trim();
        const lastName  = document.getElementById('lastName').value.trim();
        const email     = document.getElementById('email').value.trim();
        const username  = document.getElementById('username').value.trim();
        const phone     = document.getElementById('phone').value.trim();
        const password  = document.getElementById('password').value;
        const confirm   = document.getElementById('confirmPassword').value;
        const terms     = document.getElementById('terms').checked;

        if (!firstName) { showError('firstNameError', 'First name is required.'); valid = false; }
        else showError('firstNameError', '');

        if (!lastName) { showError('lastNameError', 'Last name is required.'); valid = false; }
        else showError('lastNameError', '');

        if (!email) {
            showError('emailError', 'Email address is required.'); valid = false;
        } else if (!isValidEmail(email)) {
            showError('emailError', 'Please enter a valid email address (e.g. user@example.com).'); valid = false;
        } else {
            showError('emailError', '');
        }

        if (!username) { showError('usernameError', 'Username is required.'); valid = false; }
        else showError('usernameError', '');

        if (!phone) {
            showError('phoneError', 'Phone number is required.'); valid = false;
        } else if (phone.replace(/\D/g, '').length !== 10) {
            showError('phoneError', 'Phone number must be exactly 10 digits.'); valid = false;
        } else {
            showError('phoneError', '');
        }

        if (!password) {
            showError('passwordError', 'Password is required.'); valid = false;
        } else if (password.length < 6) {
            showError('passwordError', 'Password must be at least 6 characters.'); valid = false;
        } else if (!/[0-9]/.test(password)) {
            showError('passwordError', 'Password must contain at least one number.'); valid = false;
        } else if (!/[^A-Za-z0-9]/.test(password)) {
            showError('passwordError', 'Password must contain at least one special character.'); valid = false;
        } else {
            showError('passwordError', '');
        }

        if (!confirm) {
            showError('confirmPasswordError', 'Please confirm your password.'); valid = false;
        } else if (password && confirm && password !== confirm) {
            showError('confirmPasswordError', 'Passwords do not match.'); valid = false;
        } else {
            showError('confirmPasswordError', '');
        }

        if (!terms) { showError('termsError', 'You must accept the terms to register.'); valid = false; }
        else showError('termsError', '');

        // Block if any inline duplicate error is still visible
        const usernameErr = document.getElementById('usernameError').textContent;
        const emailErr    = document.getElementById('emailError').textContent;
        const phoneErr    = document.getElementById('phoneError').textContent;
        if (usernameErr || emailErr || phoneErr) valid = false;

        if (!valid) e.preventDefault();
    });
</script>
</body>
</html>
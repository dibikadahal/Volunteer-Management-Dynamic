<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password – VolunteerHub</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
</head>
<body>

<div class="auth-wrapper">

    <!-- Left panel -->
    <div class="auth-left">
        <div class="brand">
            <div class="brand-icon">&#9825;</div>
            <span>VolunteerHub</span>
        </div>
        <div class="left-content">
            <div class="left-illustration">
                <div class="circle c1"></div>
                <div class="circle c2"></div>
                <div class="circle c3"></div>
                <div class="lock-icon unlocked"><i class="fas fa-unlock-alt"></i></div>
            </div>
            <h2>Create a new password</h2>
            <p>Choose a strong password with at least 6 characters to keep your account safe.</p>
            <div class="tips">
                <div class="tip"><i class="fas fa-check-circle"></i> At least 6 characters</div>
                <div class="tip"><i class="fas fa-check-circle"></i> Mix letters and numbers</div>
                <div class="tip"><i class="fas fa-check-circle"></i> Avoid common passwords</div>
            </div>
        </div>
    </div>

    <!-- Right panel — form -->
    <div class="auth-right">
        <div class="auth-card">

            <div class="auth-card-header">
                <div class="auth-icon-wrap green-icon">
                    <i class="fas fa-key"></i>
                </div>
                <h1>New Password</h1>
                <p>Enter and confirm your new password below</p>
            </div>

            <%-- Error message --%>
            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <%= request.getAttribute("error") %>
            </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/reset-password" method="post" class="auth-form">

                <%-- Hidden token field — carries the token through the form submission --%>
                <input type="hidden" name="token" value="${token}">

                <div class="form-group">
                    <label for="newPassword">NEW PASSWORD</label>
                    <div class="input-wrap">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password" id="newPassword" name="newPassword"
                               placeholder="Enter new password"
                               required minlength="6">
                        <button type="button" class="toggle-pass" onclick="togglePass('newPassword', this)">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">CONFIRM PASSWORD</label>
                    <div class="input-wrap">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword"
                               placeholder="Confirm your new password"
                               required minlength="6">
                        <button type="button" class="toggle-pass" onclick="togglePass('confirmPassword', this)">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>

                <!-- Password strength indicator -->
                <div class="strength-wrap">
                    <div class="strength-bar">
                        <div class="strength-fill" id="strength-fill"></div>
                    </div>
                    <span class="strength-label" id="strength-label">Password strength</span>
                </div>

                <button type="submit" class="auth-btn green-btn">
                    <i class="fas fa-shield-alt"></i> Reset Password
                </button>

            </form>

            <div class="auth-footer-link">
                <a href="${pageContext.request.contextPath}/login">
                    <i class="fas fa-arrow-left"></i> Back to Sign In
                </a>
            </div>

        </div>
    </div>

</div>

<script>
    function togglePass(fieldId, btn) {
        var field = document.getElementById(fieldId);
        var icon  = btn.querySelector('i');
        if (field.type === 'password') {
            field.type = 'text';
            icon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            field.type = 'password';
            icon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    }

    // Password strength checker
    document.getElementById('newPassword').addEventListener('input', function () {
        var val    = this.value;
        var fill   = document.getElementById('strength-fill');
        var label  = document.getElementById('strength-label');
        var score  = 0;

        if (val.length >= 6)  score++;
        if (val.length >= 10) score++;
        if (/[A-Z]/.test(val)) score++;
        if (/[0-9]/.test(val)) score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;

        var pct    = (score / 5) * 100;
        fill.style.width = pct + '%';

        if (score <= 1)      { fill.style.background = '#e05c97'; label.textContent = 'Weak'; }
        else if (score <= 3) { fill.style.background = '#f5a623'; label.textContent = 'Fair'; }
        else if (score <= 4) { fill.style.background = '#4f8ef7'; label.textContent = 'Good'; }
        else                 { fill.style.background = '#38c9b0'; label.textContent = 'Strong'; }
    });
</script>

</body>
</html>

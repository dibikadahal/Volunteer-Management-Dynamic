<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password – VolunteerHub</title>
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
                <div class="lock-icon"><i class="fas fa-lock"></i></div>
            </div>
            <h2>Forgot your password?</h2>
            <p>No worries! Enter your registered email and we'll send you a secure link to reset it.</p>
            <div class="left-stats">
                <div class="stat"><span>30 min</span><small>Link validity</small></div>
                <div class="stat"><span>100%</span><small>Secure</small></div>
                <div class="stat"><span>Fast</span><small>Delivery</small></div>
            </div>
        </div>
    </div>

    <!-- Right panel — form -->
    <div class="auth-right">
        <div class="auth-card">

            <div class="auth-card-header">
                <div class="auth-icon-wrap">
                    <i class="fas fa-envelope-open-text"></i>
                </div>
                <h1>Reset Password</h1>
                <p>Enter your email address and we'll send you a reset link</p>
            </div>

            <%-- Error message --%>
            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <%= request.getAttribute("error") %>
            </div>
            <% } %>

            <%-- Success message --%>
            <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <%= request.getAttribute("success") %>
            </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/forgot-password" method="post" class="auth-form">

                <div class="form-group">
                    <label for="email">EMAIL ADDRESS</label>
                    <div class="input-wrap">
                        <i class="fas fa-envelope input-icon"></i>
                        <input type="email" id="email" name="email"
                               placeholder="Enter your registered email"
                               required autocomplete="email">
                    </div>
                </div>

                <button type="submit" class="auth-btn">
                    <i class="fas fa-paper-plane"></i> Send Reset Link
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

</body>
</html>